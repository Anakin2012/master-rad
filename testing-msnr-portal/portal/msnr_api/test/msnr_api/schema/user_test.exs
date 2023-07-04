defmodule MsnrApi.Schema.UserTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Accounts.User
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @required_fields [
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:role, :string}
  ]

  @optional_fields [
    :id, :hashed_password, :password_url_path, :refresh_token, :inserted_at, :updated_at
  ]

  @student_registration_fields [
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:index_number, :string},
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

    test "error: returns an error changeset when given uncastable values" do
      invalid_params = invalid_params(@required_fields)

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, invalid_params)

      for {field, _} <- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
      end
    end

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
      Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)

      {:ok, existing_user} =
        %User{}
        |> User.changeset(valid_params(@required_fields))
        |> MsnrApi.Repo.insert()

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

  describe "changeset/2 with given student registration" do

    test "success: returns a valid changeset when given valid arguments" do

      params = valid_params(@student_registration_fields)
      params = Map.put(params, "status", :accepted)

      student_registration = create_registration(params)

      changeset = User.changeset(%User{}, student_registration)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @student_registration_fields, field not in [:index_number] do
        actual = Map.get(changes, field)
        expected = params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      role = Map.get(changes, :role)
      assert role == :student
    end

    test "error: returns an error changeset when given uncastable values" do

      params = invalid_params(@student_registration_fields)
      params = Map.put(params, "status", NaiveDateTime.local_now())

      student_registration = create_registration(params)

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, student_registration)

      for {field, _} <- @student_registration_fields, field not in [:index_number] do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
      end

      role = errors[:role]
      refute role == :student
    end
  end

  describe "changeset_password/2" do
    test "success: returns a valid changeset with validated and hashed password" do
      valid_params = valid_params(@required_fields)
                    |> Map.put("password", "pass123")

      changeset = User.changeset_password(%User{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      actual = Map.get(changes, :password)
      expected = valid_params[Atom.to_string(:password)]
      assert actual == expected,
        "Values did not match for: password\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"

      assert _actual_hashed = Map.get(changes, :hashed_password)
    end

    test "error: returns an error changeset when given uncastable password value" do
      invalid_params = valid_params(@required_fields)
                       |> Map.put("password", NaiveDateTime.utc_now())

      assert %Changeset{valid?: false, errors: errors} = User.changeset_password(%User{}, invalid_params)

      assert errors[:password], "the field :password is missing from errors."
      {_, meta} = errors[:password]
      assert meta[:validation] == :cast,
        "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when password field is missing" do
      params = valid_params(@required_fields)

      assert %Changeset{valid?: false, errors: errors} = User.changeset_password(%User{}, params)

      assert errors[:password], "The field :password is missing from errors."
      {_, meta} = errors[:password]
      assert meta[:validation] == :required,
        "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when password is too short" do
      params = valid_params(@required_fields)
               |> Map.put("password", "ana")

      assert %Changeset{valid?: false, errors: errors} = User.changeset_password(%User{}, params)

      assert errors[:password], "The field :password is missing from errors."
      {_, meta} = errors[:password]
      assert meta[:validation] == :length,
        "The validation type #{meta[:validation]} is incorrect."
    end
  end

  describe "changeset_token/2" do
    test "success: returns a valid changeset with refresh token" do
      valid_params = valid_params(@required_fields)
                    |> Map.put("refresh_token", Ecto.UUID.generate())

      changeset = User.changeset_token(%User{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      actual = Map.get(changes, :refresh_token)
      expected = valid_params[Atom.to_string(:refresh_token)]
      assert actual == expected,
        "Values did not match for: password\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
    end

    test "error: returns an error changeset when given uncastable refresh token value" do
      invalid_params = valid_params(@required_fields)
                       |> Map.put("refresh_token", NaiveDateTime.utc_now())

      assert %Changeset{valid?: false, errors: errors} = User.changeset_token(%User{}, invalid_params)

      assert errors[:refresh_token], "the field :refresh_token is missing from errors."
      {_, meta} = errors[:refresh_token]
      assert meta[:validation] == :cast,
        "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when refresh token field is missing" do
      params = valid_params(@required_fields)

      assert %Changeset{valid?: false, errors: errors} = User.changeset_token(%User{}, params)

      assert errors[:refresh_token], "The field :refresh_token is missing from errors."
      {_, meta} = errors[:refresh_token]
      assert meta[:validation] == :required,
        "The validation type #{meta[:validation]} is incorrect."
    end

  end

  defp create_registration(params) do
    %StudentRegistration{
      email: Map.get(params, "email"),
      first_name: Map.get(params, "first_name"),
      last_name: Map.get(params, "last_name"),
      index_number: Map.get(params, "index_number"),
      status: Map.get(params, "status")}
  end
end
