defmodule MsnrApi.Queries.TopicsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Semesters, Semesters.Semester, Topics, Topics.Topic, Groups, Groups.Group}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    {:ok, active_semester} = Semesters.update_semester(semester, params)
  end

  describe "list_topics/1" do

    test "success: returns a list of topics in the given semester" do
      {:ok, semester} = setup_semester()
      topics = [Factory.insert(:topic), Factory.insert(:topic), Factory.insert(:topic)]

      actual = Topics.list_topics(%{"semester_id" => semester.id})
      assert topics == actual
    end

    test "success: returns an empty list when no topics in given semester" do

      {:ok, semester} = setup_semester()

      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM topics")

      assert [] == Topics.list_topics(%{"semester_id" => semester.id})
    end

    test "success: returns an empty list when given invalid semester id" do
      assert [] == Topics.list_topics(%{"semester_id" => -1})
    end
  end

  describe "list_topics/2" do
    {:ok, semester} = setup_semester()
    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)

    student1 = Factory.insert(:student, user_id: user1.id, semesters: [active_semester], user: user1)
    student2 = Factory.insert(:student, user_id: user2.id, semesters: [active_semester], user: user2)
    {:ok, %{group: group}} = Groups.create_group(%{semester_id: semester.id, students: [student1.user_id, student2.user_id]})


  end

  describe "get_topic/1" do
    test "success: it returns a topic when given a valid id" do
      setup_semester()
      existing_topic = Factory.insert(:topic)

      assert returned_topic = Topics.get_topic!(existing_topic.id)

      assert returned_topic == existing_topic
    end

    test "error: it returns an error tuple when a topic doesn't exist" do

      invalid_id = -1
      assert_raise Ecto.NoResultsError, fn ->
        Topics.get_topic!(invalid_id) end
    end
  end

  describe "create_topic/1" do

    test "success: it inserts a topic in the db and returns the topic" do

      setup_semester()
      params = Factory.string_params_for(:topic)

      assert {:ok, %Topic{} = returned_topic} = Topics.create_topic(params)

      actual = returned_topic |> Map.from_struct()
                              |> Map.drop([:semester])

      topic_from_db = Repo.get(Topic, returned_topic.id)
                               |> Map.from_struct()
                               |> Map.drop([:semester])

      assert actual == topic_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(topic_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert topic_from_db.inserted_at == topic_from_db.updated_at
    end

    test "error: returns an error tuple when topic can't be created" do
      {:ok, semester} = setup_semester()
      missing_params = %{"semester_id" => semester.id}

      assert {:error, %Changeset{valid?: false}} = Topics.create_topic(missing_params)
    end
  end

  describe "update_topic/2" do
    test "success: it updates database and returns the topic" do

      setup_semester()
      existing_topic = Factory.insert(:topic)

      params = Factory.string_params_for(:topic)
               |> Map.take(["title"])

      assert {:ok, returned_topic} = Topics.update_topic(existing_topic, params)

      topic_from_db = Repo.get(Topic, returned_topic.id)
      assert returned_topic == topic_from_db

      expected_topic_data = existing_topic
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:title, params["title"])

      for {field, expected} <- expected_topic_data do
        actual = Map.get(topic_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end


  end

  describe "delete_topic/1" do

    test "success: it deletes the topic" do
      setup_semester()
      topic = Factory.insert(:topic)

      assert {:ok, _deleted_topic} = Topics.delete_topic(topic)

      refute Repo.get(Topic, topic.id)
    end
  end

  describe "selected_topics_ids/1" do
    test "success: returns a list of topic ids from a given semester" do
      {:ok, semester} = setup_semester()
      topics_ids = [Factory.insert(:topic).id, Factory.insert(:topic).id, Factory.insert(:topic).id]
      groups = [Factory.insert(:group), Factory.insert(:group), Factory.insert(:group)]

      for {group, topic_id} <- Enum.zip(groups, topics_ids),
      into: [] do
        params = %{"topic_id" => topic_id}
        {:ok, group} = Groups.update_group(group, params)
      end
      ids = Topics.selected_topics_ids(semester.id)

      assert topics_ids == ids

    end
  end

end
