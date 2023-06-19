defmodule MsnrApi.Queries.ActivitiesTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Activities, Activities.Activity}
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
    test "success: it inserts an activity in the db and returns the activity" do

      semester = Factory.insert(:semester)
      activity_type = Factory.insert(:activity_type)
      params = Factory.string_params_for(:activity)
              |> Map.put("activity_type_id", activity_type.id)

      semester_id = Integer.to_string(semester.id)

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


end
