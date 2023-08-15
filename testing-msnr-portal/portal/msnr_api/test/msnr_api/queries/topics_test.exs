defmodule MsnrApi.Queries.TopicsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Semesters, Semesters.Semester, Topics, Topics.Topic, Groups, Groups.Group, Students}
  alias MsnrApi.{Students.StudentSemester}
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

    test "success: returns only available topics" do
      {:ok, semester} = setup_semester()
      params_topic = Factory.string_params_for(:topic)
      {:ok, topic} = Topics.create_topic(params_topic)
      {:ok, group} =   %Group{}
                      |> Group.changeset(%{"topic_id" => topic.id})
                      |> Repo.insert()

      {:ok, available}= Factory.string_params_for(:topic)
                      |> Topics.create_topic()

      assert [available] == Topics.list_topics(%{"semester_id" => semester.id, "available" => "true"})
    end

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
    test "success :it updates the value" do
      setup_semester()
      existing_topic = Factory.insert(:topic)

      params = %{"title" => "new"}
      assert {:ok, returned_topic} = Topics.update_topic(existing_topic, params)

      topic_from_db = Repo.get(Topic, returned_topic.id)
      assert returned_topic == topic_from_db

      expected_topic_data = existing_topic
                          |> Map.from_struct()
                          |> Map.drop([:__meta__, :updated_at])
                          |> Map.put(:title, "new")

      for {field, expected} <- expected_topic_data do
        actual = Map.get(topic_from_db, field)

      assert actual == expected,
        "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
    end
  end

    test "error: returns an error tuple when cant update" do
      setup_semester()
      existing_topic = Factory.insert(:topic)

      bad_params = %{"title" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Topics.update_topic(existing_topic, bad_params)

      assert existing_topic == Repo.get(Topic, existing_topic.id)
    end
  end

  describe "selected_topic_ids/1" do
    test "success: returns all taken topic ids in semester" do
      {:ok, semester} = setup_semester()

      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)
                     |> Map.put("user", user)

      {:ok, student} = Students.create_student(user, params_student)

      user2 = Factory.insert(:user)
      params_student2 = Factory.string_params_for(:student)
                     |> Map.put("user", user2)

      {:ok, student2} = Students.create_student(user2, params_student2)

      params_topic = Factory.string_params_for(:topic)
      {:ok, topic} = Topics.create_topic(params_topic)

      {:ok, group} = %Group{}
                     |> Group.changeset(%{"topic_id" => topic.id,
                                           "semester_id" => semester.id,
                                           "students" => [student.user_id, student2.user_id]})
                     |> Repo.insert()

      Repo.update_all(StudentSemester, set: [group_id: group.id])
      assert [topic.id] == Topics.selected_topics_ids(semester.id)
    end

    test "success: returns empty list when no taken topics" do
      {:ok, semester} = setup_semester()
      assert [] == Topics.selected_topics_ids(semester.id)
    end
  end

  describe "next_topic_number/1" do
    test "success: returns number 1 when no topics in semester" do
      {:ok, semester} = setup_semester()

      assert 1 == Topics.next_topic_number(semester.id)
    end

    test "success: returns the next one when there are topics" do
      {:ok, semester} = setup_semester()
      params = Factory.string_params_for(:topic)

      existing_topic = Topics.create_topic(params)

      assert 2 == Topics.next_topic_number(semester.id)
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



end
