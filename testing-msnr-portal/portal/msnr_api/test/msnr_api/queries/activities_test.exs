defmodule MsnrApi.Queries.ActivitiesTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Groups.Group, Topics, Students.StudentSemester, Semesters, Activities, Activities.Activity, ActivityTypes, ActivityTypes.ActivityType, Students}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_activities/0" do

    test "success: returns a list of all activites" do
      existing_activites = [
        Factory.insert(:activity),
        Factory.insert(:activity),
        Factory.insert(:activity)
      ]

      assert retrieved_activities = Activities.list_activities()

      assert retrieved_activities == existing_activites
    end

    test "success: returns an empty list when no activities" do
      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM activities")

      assert [] == Activities.list_activities()
    end
  end

  describe "get_activity/1" do

    test "success: it returns an activity when given a valid id" do
      existing_activity = Factory.insert(:activity)

      assert returned_activity = Activities.get_activity!(existing_activity.id)

      assert returned_activity == existing_activity
    end

    test "error: it returns an error tuple when an activity doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Activities.get_activity!(-1) end
    end
  end

  describe "create_activity/2" do
    test "success: it inserts a group activity in the db and returns the activity" do

      at_params = get_at_params("group", true, false)
      {:ok, %ActivityType{} = activity_type} = ActivityTypes.create_activity_type(at_params)
      {:ok, semester} = setup_semester()
      semester_id = Integer.to_string(semester.id)
      {params, _} = prepare_activity(semester, activity_type)

      assert {:ok, %Activity{} = returned_activity} = Activities.create_activity(semester_id, params)

      activity_from_db = Repo.get(Activity, returned_activity.id)
      assert returned_activity == activity_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(activity_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert activity_from_db.inserted_at == activity_from_db.updated_at
    end

    test "success: it inserts a review activity" do
      at_params = get_at_params("review", false, false)
      {:ok, %ActivityType{} = activity_type} = ActivityTypes.create_activity_type(at_params)
      {:ok, semester} = setup_semester()
      semester_id = Integer.to_string(semester.id)
      {params, students} = prepare_activity(semester, activity_type)

      setup_topic(students, semester)
      assert {:ok, %Activity{} = returned_activity} = Activities.create_activity(semester_id, params)

      activity_from_db = Repo.get(Activity, returned_activity.id)
      assert returned_activity == activity_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(activity_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert activity_from_db.inserted_at == activity_from_db.updated_at
    end

    test "error: zero divide when no topics" do
      at_params = get_at_params("review", false, false)
      {:ok, %ActivityType{} = activity_type} = ActivityTypes.create_activity_type(at_params)
      {:ok, semester} = setup_semester()
      semester_id = Integer.to_string(semester.id)
      {params, _} = prepare_activity(semester, activity_type)

      assert_raise ArithmeticError, fn ->
        Activities.create_activity(semester_id, params) end
    end

    test "error: returns an error tuple when activity can't be created" do
      semester = Factory.insert(:semester)
      semester_id = Integer.to_string(semester.id)
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Activities.create_activity(semester_id, missing_params)
    end
  end

  describe "update_activity/2" do
    test "success: it updates database and returns the activity" do

      semester = Factory.insert(:semester)
      activity_type = Factory.insert(:activity_type)
      existing_activity = Factory.insert(:activity)

      params = Factory.string_params_for(:activity)
        |> Map.put("semester_id", Integer.to_string(semester.id))
        |> Map.put("activity_type_id", Integer.to_string(activity_type.id))
        |> Map.take(["points", "semester_id", "activity_type_id"])

      assert {:ok, returned_activity} = Activities.update_activity(existing_activity, params)

      activity_from_db = Repo.get(Activity, returned_activity.id)
      assert returned_activity == activity_from_db

      expected_activity_data = existing_activity
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:points, params["points"])
        |> Map.put(:semester_id, String.to_integer(params["semester_id"]))
        |> Map.put(:activity_type_id, String.to_integer(params["activity_type_id"]))


      for {field, expected} <- expected_activity_data do
        actual = Map.get(activity_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when activity can't be updated" do

      existing_activity = Factory.insert(:activity)

      bad_params = %{"points" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Activities.update_activity(existing_activity, bad_params)

      assert existing_activity == Repo.get(Activity, existing_activity.id)
    end
  end

  describe "delete_activity/1" do

    test "success: it deletes the activity" do

      activity = Factory.insert(:activity)
      assert {:ok, _deleted_activity} = Activities.delete_activity(activity)

      refute Repo.get(Activity, activity.id)
    end
  end

  defp setup_topic(students, semester) do
    params_topic = Factory.string_params_for(:topic)
    {:ok, topic} = Topics.create_topic(params_topic)

    {:ok, group} = %Group{}
                   |> Group.changeset(%{"topic_id" => topic.id,
                                        "semester_id" => semester.id,
                                        "students" => students})
                   |> Repo.insert()

    Repo.update_all(StudentSemester, set: [group_id: group.id])
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end

  defp get_at_params(code, is_group, has_signup) do

    %{"name" => "aktivnost",
      "description" => "opis",
      "code" => code,
      "has_signup" => has_signup,
      "is_group" => is_group,
      "content" => %{"" => [""]}
     }
  end

  defp prepare_activity(semester, activity_type) do

    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
    params_student = Factory.string_params_for(:student)
                     |> Map.put("user", user1)
    params_student2 = Factory.string_params_for(:student)
                        |> Map.put("user", user2)
    {:ok, student1} = Students.create_student(user1, params_student)
    {:ok, student2} = Students.create_student(user2, params_student2)

    params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("end_date", System.os_time(:second)+10000)

    {params, [student1, student2]}
  end


end
