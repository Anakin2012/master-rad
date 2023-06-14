defmodule MsnrApi.Schema.DocumentTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Documents.Document

  @required_fields [
    {:file_name, :string},
    {:file_path, :string},
    {:creator_id, :id}
  ]

  @optional_fields [
    :id, :inserted_at, :updated_at
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:file_name, :string},
    {:file_path, :string},
    {:creator_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Document.__schema__(:fields) do
          type = Document.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@required_fields)
      changeset = Document.changeset(%Document{}, valid_params)

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

      assert %Changeset{valid?: false, errors: errors} = Document.changeset(%Document{}, invalid_params)

      for {field, _}<- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = Document.changeset(%Document{}, params)

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

  end

end
