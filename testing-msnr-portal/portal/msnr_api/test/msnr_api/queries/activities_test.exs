defmodule MsnrApi.Queries.ActivitiesTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Activities, Activities.Activity}
  alias Ecto.Changeset
  import MsnrApi.Support.Factory

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
        Activities.get_activity!(Enum.random(5000..6000 )) end

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
