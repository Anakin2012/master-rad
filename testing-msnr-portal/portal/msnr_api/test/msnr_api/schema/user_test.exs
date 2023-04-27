defmodule MsnrApi.Schema.UserTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias MsnrApi.Accounts.User

  @required_fields [
    :email,
    :first_name,
    :last_name,
    :role
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
      valid_params = %{
        "email" => "ana@gmail.com",
        "first_name" => "Name",
        "last_name" => "LastName",
        "role" => "student"
      }
      changeset = User.changeset(%User{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, } <- @expected_fields_with_types do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error changeset when given uncastable values" do
      invalid_params = %{
        "email" => 1,
        "first_name" => 2,
        "last_name" => 3,
        "role" => 4
      }

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, invalid_params)

      for {field, _} <- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type. #{meta[:validaiton]}, is incorrect."
      end
    end

    test "error: returns an error changeset when given invalid role" do
      invalid_params = %{
        "email" => "email",
        "first_name" => "ana",
        "last_name" => "petrovic",
        "role" => "not student and not professor"
      }

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, invalid_params)
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = User.changeset(%User{}, params)

      for {field, _} <- @expected_fields_with_types, field not in @optional do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :required,
          "The validation type. #{meta[:validaiton]}, is incorrect."
      end
    end

  end

end
