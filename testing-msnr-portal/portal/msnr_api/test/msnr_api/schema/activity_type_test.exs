defmodule MsnrApi.Schema.ActivityTypeTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.ActivityTypes.ActivityType

  @required_fields [
    {:name, :string},
    {:code, :string},
    {:description, :string},
    {:content, :map}
  ]

  @optional_fields [
    :id, :inserted_at, :updated_at
  ]

  @default [
    :has_signup,
    :is_group
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:name, :string},
    {:code, :string},
    {:description, :string},
    {:has_signup, :boolean},
    {:is_group, :boolean},
    {:content, :map},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- ActivityType.__schema__(:fields) do
          type = ActivityType.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@required_fields)
      changeset = ActivityType.changeset(%ActivityType{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @required_fields do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an invalid changeset when given uncastable values" do
      invalid_params = invalid_params(@required_fields)

      assert %Changeset{valid?: false, errors: errors} = ActivityType.changeset(%ActivityType{}, invalid_params)

      for {field, _} <- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validaiton]} is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = ActivityType.changeset(%ActivityType{}, params)

      for {field, _} <- @required_fields, field not in @default do
        assert errors[field], "The field #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :required,
        "The validation type #{meta[:validation]} is incorrect."
      end

      for field <- @optional_fields do
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end

      for field <- @default do
        refute errors[field], "The default field #{field} is not default when it should be"
      end
    end

    test "error: returns an error changeset when name or code is reused" do
      Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)

      {:ok, existing_activity_type} =
        %ActivityType{}
        |> ActivityType.changeset(valid_params(@required_fields))
        |> MsnrApi.Repo.insert()

      changeset_with_reused_fields =
        %ActivityType{}
        |> ActivityType.changeset(valid_params(@required_fields)
                          |> Map.put("name", existing_activity_type.name)
                          |> Map.put("code", existing_activity_type.code))

      assert {:error, %Changeset{valid?: false, errors: errors}} =
        MsnrApi.Repo.insert(changeset_with_reused_fields)


      for {field, _} <- [:name, :code] do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:constraint] == :unique,
          "The validation type #{meta[:validaiton]} is incorrect."
      end
    end

  end

end
