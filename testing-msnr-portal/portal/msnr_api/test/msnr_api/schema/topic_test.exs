defmodule MsnrApi.Schema.TopicTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Topics.Topic

  @required_fields [
    {:title, :string},
    {:semester_id, :id}
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:title, :string},
    {:number, :integer},
    {:semester_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Topic.__schema__(:fields) do
          type = Topic.__schema__(:type, field)
          {field, type}
        end
      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do

      valid_params = valid_params(@required_fields)
      changeset = Topic.changeset(%Topic{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @required_fields do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an invalid changeset when given uncastable values" do
      invalid_params = invalid_params([{:title, :string}])
      valid_params = valid_params([{:semester_id, :id}])
      params = Map.merge(invalid_params, valid_params)

      assert %Changeset{valid?: false, errors: errors} = Topic.changeset(%Topic{}, params)

      assert errors[:title], "the field: :title is missing from errors."

      {_, meta} = errors[:title]
      assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when required fields are missing" do
      params = valid_params([{:semester_id, :id}])

      assert %Changeset{valid?: false, errors: errors} = Topic.changeset(%Topic{}, params)

      assert errors[:title], "the field: :title is missing from errors."

      {_, meta} = errors[:title]
      assert meta[:validation] == :required,
          "The validation type #{meta[:validation]} is incorrect."
    end
  end

end
