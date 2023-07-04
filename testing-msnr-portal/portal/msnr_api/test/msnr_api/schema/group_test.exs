defmodule MsnrApi.Schema.GroupTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Groups.Group
  alias MsnrApi.Topics.Topic
  alias MsnrApi.Semesters.Semester


  @required_fields [
    {:topic_id, :id}
  ]

  @optional_fields [
    :id, :inserted_at, :updated_at
  ]

  @expected_fields_with_types [
    {:id, :id},
    {:topic_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Group.__schema__(:fields) do
          type = Group.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@required_fields)
      changeset = Group.changeset(%Group{}, valid_params)

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

      assert %Changeset{valid?: false, errors: errors} = Group.changeset(%Group{}, invalid_params)

      assert errors[:topic_id], "the field topic_id is missing from errors."

      {_, meta} = errors[:topic_id]
      assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} = Group.changeset(%Group{}, params)

      assert errors[:topic_id], "The field topic_id is missing from errors."

      {_, meta} = errors[:topic_id]

      assert meta[:validation] == :required,
        "The validation type #{meta[:validation]} is incorrect."

      for field <- @optional_fields do
        refute errors[field], "The optional field #{field} is required when it shouldn't be."
      end
    end

    test "error: returns an error changeset when topic_id is reused" do

      Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)

      {:ok, existing_semester} = insert_semester()
      {:ok, existing_topic} = insert_topic(existing_semester)
      {:ok, existing_group} = insert_group(existing_topic)

      changeset_with_reused_topic_id =
        %Group{}
        |> Group.changeset(valid_params(@required_fields)
                          |> Map.put("topic_id", existing_group.topic_id))

      assert {:error, %Changeset{valid?: false, errors: errors}} =
        MsnrApi.Repo.insert(changeset_with_reused_topic_id)

      assert errors[:topic_id], "The field :topic_id is missing from errors."

      {_, meta} = errors[:topic_id]

      assert meta[:constraint] == :unique,
        "The validation type #{meta[:validation]} is incorrect."

    end
  end

  defp insert_semester() do
    {:ok, _existing_semester} =
      %Semester{}
      |> Semester.changeset(valid_params([
        {:year, :integer},
        {:is_active, :boolean}
      ]))
      |> MsnrApi.Repo.insert()
  end

  defp insert_topic(semester) do
    {:ok, _existing_topic} =
      %Topic{}
      |> Topic.changeset(Map.put(valid_params([{:title, :string}]), "semester_id", semester.id))
      |> MsnrApi.Repo.insert()
  end

  defp insert_group(topic) do
    {:ok, _existing_group} =
      %Group{}
      |> Group.changeset(%{"topic_id" => topic.id})
      |> MsnrApi.Repo.insert()
  end

end
