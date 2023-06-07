defmodule MsnrApi.Schema.AssignmentTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Assignments.Assignment

  @required_fields [
    {:grade, :integer},
    {:comment, :string}
  ]

  @optional_fields [
    :id, :completed, :student_id, :group_id, :activity_id, :related_topic_id, :inserted_at, :updated_at
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:grade, :integer},
    {:comment, :string},
    {:completed, :boolean},
    {:student_id, :id},
    {:group_id, :id},
    {:activity_id, :id},
    {:related_topic_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Assignment.__schema__(:fields) do
          type = Assignment.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@required_fields)
      changeset = Assignment.changeset(%Assignment{}, valid_params)

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

      assert %Changeset{valid?: false, errors: errors} = Assignment.changeset(%Assignment{}, invalid_params)

      for {field, _} <- @required_fields do
        assert errors[field], "the field: #{field} is missing from errors."

        {_, meta} = errors[field]
        assert meta[:validation] == :cast,
          "The validation type #{meta[:validaiton]} is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = Assignment.changeset(%Assignment{}, params)

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

  describe "signup_changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params([:completed])
      changeset = Assignment.signup_changeset(%Assignment{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      actual = Map.get(changes, :completed)
      expected = valid_params[Atom.to_string(:completed)]
      assert actual == expected,
      "Values did not match for: :completed\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"

    end

    test "error: returns an invalid changeset when given uncastable values" do
      invalid_params = invalid_params([{:completed, :boolean}])

      assert %Changeset{valid?: false, errors: errors} = Assignment.signup_changeset(%Assignment{}, invalid_params)

      assert errors[:completed], "the field :completed is missing from errors."
      {_, meta} = errors[:completed]
      assert meta[:validation] == :cast,
        "The validation type #{meta[:validaiton]} is incorrect."
    end

  end


end
