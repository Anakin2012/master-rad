defmodule MsnrApi.Schema.TopicTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Topics.Topic
  alias MsnrApi.Semesters.Semester

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

    test "success: returns a changeset with valid topic number when given valid arguments" do
      {:ok, existing_semester} = insert_semester()
      {:ok, existing_topic} = insert_topic(existing_semester)

      valid_params = %{"title" => "new title", "semester_id" => existing_semester.id}
      changeset = Topic.changeset(%Topic{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      assert Map.get(changes, :number) == (existing_topic.number + 1)
    end

    test "error: returns an invalid changeset when given uncastable title value" do
     invalid_params = invalid_params([{:title, :string}])
     valid_params = valid_params([{:semester_id, :id}])
     params = Map.merge(invalid_params, valid_params)

    assert %Changeset{valid?: false, errors: errors} = Topic.changeset(%Topic{}, params)

    assert errors[:title], "the field: :title is missing from errors."

    {_, meta} = errors[:title]
    assert meta[:validation] == :cast,
      "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when required field title is missing" do
      params = valid_params([{:semester_id, :id}])

      assert %Changeset{valid?: false, errors: errors} = Topic.changeset(%Topic{}, params)

      assert errors[:title], "the field: :title is missing from errors."

      {_, meta} = errors[:title]
      assert meta[:validation] == :required,
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

end
