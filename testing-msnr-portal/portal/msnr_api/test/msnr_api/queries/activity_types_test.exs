defmodule MsnrApi.Queries.ActivityTypesTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{ActivityTypes, ActivityTypes.ActivityType}
  alias Ecto.Changeset
  import MsnrApi.Support.Factory

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_activity_types/0" do

#    test "success: returns a list of all activity types" do
 #     existing_activity_types = [
  #      Factory.insert(:activity_type),
   #     Factory.insert(:activity_type),
    # ]

     # assert retrieved_activity_types = ActivityTypes.list_activity_types()

      #assert retrieved_activity_types == existing_activity_types
    #end

    test "success: returns an empty list when no users" do
      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM activity_types")

      assert [] == ActivityTypes.list_activity_types()
    end
  end

  describe "get_activity_type!/1" do

    test "success: it returns an activity type when given a valid id" do
      existing_activity_type = Factory.insert(:activity_type)

      assert returned_activity_type = ActivityTypes.get_activity_type!(existing_activity_type.id)

      assert returned_activity_type == existing_activity_type
    end

    test "error: it returns an error tuple when activity type doesn't exist" do

      assert_raise Ecto.NoResultsError, fn ->
        ActivityTypes.get_activity_type!(Enum.random(5000..6000 )) end

    end
  end

  describe "create_activity_type/1" do

    test "success: it inserts an activity type in the db and returns the activity type" do

      params = Factory.string_params_for(:activity_type)
      assert {:ok, %ActivityType{} = returned_activity_type} = ActivityTypes.create_activity_type(params)

      activity_type_from_db = Repo.get(ActivityType, returned_activity_type.id)
      assert returned_activity_type == activity_type_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(activity_type_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert activity_type_from_db.inserted_at == activity_type_from_db.updated_at
    end

    test "error: retunrs an error tuple when activity type can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = ActivityTypes.create_activity_type(missing_params)
    end
  end

  describe "update_activity_type/2" do

    test "success: it updates database and returns the activity type" do

      existing_activity_type = Factory.insert(:activity_type)

      params = Factory.string_params_for(:activity_type)
        |> Map.take(["name"])

      assert {:ok, returned_activity_type} = ActivityTypes.update_activity_type(existing_activity_type, params)

      activity_type_from_db = Repo.get(ActivityType, returned_activity_type.id)
      assert returned_activity_type == activity_type_from_db

      expected_activity_type_data = existing_activity_type
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:name, params["name"])

      for {field, expected} <- expected_activity_type_data do
        actual = Map.get(activity_type_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      # refute user_from_db.updated_at == existing_user.updated_at
      # assert %DateTime{} = user_from_db.updated_at
    end

    test "error: returns an error tuple when activity type can't be updated" do

      existing_activity_type = Factory.insert(:activity_type)

      bad_params = %{"name" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = ActivityTypes.update_activity_type(existing_activity_type, bad_params)

      assert existing_activity_type == Repo.get(ActivityType, existing_activity_type.id)
    end
  end

  describe "delete_activity_type/1" do

    test "success: it deletes the activity type" do

      activity_type = Factory.insert(:activity_type)

      assert {:ok, _deleted_activity_type} = ActivityTypes.delete_activity_type(activity_type)

      refute Repo.get(ActivityType, activity_type.id)
    end

  end


end
