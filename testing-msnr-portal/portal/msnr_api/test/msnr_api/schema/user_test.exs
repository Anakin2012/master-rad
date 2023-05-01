defmodule MsnrApi.Schema.UserTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Accounts.User

  @required_fields [
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:role, :string}
  ]

  @optional_fields [
    :id, :hashed_password, :password_url_path, :refresh_token, :inserted_at, :updated_at
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:hashed_password, :string},
    {:password_url_path, Ecto.UUID},
    {:refresh_token, Ecto.UUID},
    {:role, {:parameterized, Ecto.Enum,
    %{
      mappings: [
        student: "student",
        professor: "professor"
      ],
      on_cast: %{
        "professor" => :professor,
        "student" => :student
      },
      on_dump: %{
        professor: "professor",
        student: "student"
      },
      on_load: %{
        "professor" => :professor,
        "student" => :student
      },
      type: :string
      }}
    },
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  # testiramo uspesan scenario, prvo prosledimo argumente - kreiramo mapu
  # validnih parametara sa ispravnim podacima
  # prvi assert - radimo pattern matching sa nasom changeset strukturom
  # da li je pattern ispravan i promene da li je jednak ovom changesetu koji smo napravili
  # nakon sto ynamo da changeset validan
  # hocemo da ynamo i da su nam parametri tacno ono sto ocekujemo
  # loopujemo kroy ocekivana polja
  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@required_fields)
      changeset = User.changeset(%User{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @required_fields do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    # pravim mapu sa nevalidnim parametrima, stavljam pogresne tipove
    # sad assertujem da mi changeset bude invalid, i umesto changes,
    # dobijam listu errors
    test "error: returns an error changeset when given uncastable values" do
      invalid_params = invalid_params(@required_fields)

      #ovo samo kaze da changeset nije validan
      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, invalid_params)

      #ovde zapravo proveravamo da tipovi nisu castable
      for {field, _} <- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        # ovde proveramo da je u pitanju cast greska,
        # pattern matchujem meta podatke dohvatam iz gresaka
        # error[field] vraca mapu i druga vrednost su ti meta podaci
        # unutar te meta liste postoji key :validation koji treba da bude cast
        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validaiton]} is incorrect."
      end
    end

    #ovde treba da dobijemo required error
    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, params)

      for {field, _} <- @required_fields do
        assert errors[field], "The field #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :required,
        "The validation type #{meta[:validation]} is incorrect."
      end

      for field <- @optional_fields do
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end
    end

    test "error: returns an error changeset when an email is reused" do
      # konekcja na bazu
      Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)

      # ubacujemo novog korisnika u bazu
      {:ok, existing_user} =
        %User{}
        |> User.changeset(valid_params(@required_fields))
        |> MsnrApi.Repo.insert()

      #sad hocu da napravim jos jedan sa istim mejlom
      changeset_with_reused_email =
        %User{}
        |> User.changeset(valid_params(@required_fields)
                          |> Map.put("email", existing_user.email))

      assert {:error, %Changeset{valid?: false, errors: errors}} =
        MsnrApi.Repo.insert(changeset_with_reused_email)

      assert errors[:email], "The field :email is missing from errors."

      {_, meta} = errors[:email]

      assert meta[:constraint] == :unique,
      "The validation type #{meta[:validation]} is incorrect."

    end

  end
end
