defmodule MsnrApi.Queries.AssignmentsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Assignments, Assignments.Assignment, Activities, Activities.Activity}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_assignments/1" do
    test "success: it lists all the assignments for a semester" do

    end
  end

  describe "get_assignment/1" do
    test "success: it returns an assignment when given a valid id" do
      existing_assignment = Factory.insert(:assignment)

      assert returned_assignment = Assignments.get_assignment!(existing_assignment.id)

      assert returned_assignment == existing_assignment
    end

    test "error: it returns an error tuple when assignment doesn't exist" do

      assert_raise Ecto.NoResultsError, fn ->
        Assignments.get_assignment!(Enum.random(5000..6000)) end

    end
  end

  describe "create_assignment/1" do

    test "success: it inserts an assignment in the db and returns the assignment" do

      params = Factory.string_params_for(:assignment)

      assert {:ok, %Assignment{} = returned_assignment} = Assignments.create_assignment(params)

      assignment_from_db = Repo.get(Assignment, returned_assignment.id)
      assert returned_assignment == assignment_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(assignment_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert assignment_from_db.inserted_at == assignment_from_db.updated_at
    end

    test "error: returns an error tuple when assignment can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Assignments.create_assignment(missing_params)
    end
  end

  describe "update_assignment/2" do

    test "success: it updates database and returns the assignment" do

      existing_assignment = Factory.insert(:assignment)

      params = Factory.string_params_for(:assignment)
        |> Map.take(["grade"])

      assert {:ok, returned_assignment} = Assignments.update_assignment(existing_assignment, params)

      assignment_from_db = Repo.get(Assignment, returned_assignment.id)
      assert returned_assignment == assignment_from_db

      expected_assignment_data = existing_assignment
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:grade, params["grade"])

      for {field, expected} <- expected_assignment_data do
        actual = Map.get(assignment_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      # refute assignment_from_db.updated_at == existing_assignment.updated_at
      # assert %DateTime{} = assignment_from_db.updated_at
    end

    test "error: returns an error tuple when assignment can't be updated" do

      existing_assignment = Factory.insert(:assignment)

      bad_params = %{"grade" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Assignments.update_assignment(existing_assignment, bad_params)

      assert existing_assignment == Repo.get(Assignment, existing_assignment.id)
    end
  end

  describe "delete_assignment/1" do
    test "success: it deletes the assignment" do

      assignment = Factory.insert(:assignment)

      assert {:ok, _deleted_assignment} = Assignments.delete_assignment(assignment)

      refute Repo.get(Assignment, assignment.id)
    end
  end

end
