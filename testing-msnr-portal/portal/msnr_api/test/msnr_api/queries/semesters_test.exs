defmodule MsnrApi.Queries.SemestersTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Semesters, Semesters.Semester}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_semester/0" do
    test "success: gets all the semesters from database" do
      existing_semesters = [
        Factory.insert(:semester),
        Factory.insert(:semester),
        Factory.insert(:semester)
      ]

      assert retrieved_semesters = Semesters.list_semester()
      assert retrieved_semesters == existing_semesters
    end

    test "success: returns an empty list when no semesters" do
      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM semesters")

      assert [] == Semesters.list_semester()
    end
  end

  describe "get_semester!/1" do

    test "success: it returns a semester when given a valid id" do
      existing_semester = Factory.insert(:semester)

      assert returned_semester = Semesters.get_semester!(existing_semester.id)

      assert returned_semester == existing_semester
    end

    test "error: it returns an error tuple when a semester doesn't exist" do

      invalid_id = -1
      assert_raise Ecto.NoResultsError, fn ->
        Semesters.get_semester!(invalid_id) end
    end
  end

  describe "create_semester/1" do
    test "success: it inserts a semester in the db and returns the semester" do

      params = Factory.string_params_for(:semester)

      assert {:ok, %Semester{} = returned_semester} = Semesters.create_semester(params)

      semester_from_db = Repo.get(Semester, returned_semester.id)
      assert returned_semester == semester_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(semester_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert semester_from_db.inserted_at == semester_from_db.updated_at
    end

    test "error: returns an error tuple when semester can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Semesters.create_semester(missing_params)
    end
  end

  describe "update_semester/2" do

    test "success: it updates database and returns the semester" do

      existing_semester = Factory.insert(:semester)

      params = Factory.string_params_for(:semester)
        |> Map.take(["year"])

      assert {:ok, returned_semester} = Semesters.update_semester(existing_semester, params)

      semester_from_db = Repo.get(Semester, returned_semester.id)
      assert returned_semester == semester_from_db

      expected_semester_data = existing_semester
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:year, params["year"])

      for {field, expected} <- expected_semester_data do
        actual = Map.get(semester_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when semester can't be updated" do

      existing_semester = Factory.insert(:semester)

      bad_params = %{"year" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Semesters.update_semester(existing_semester, bad_params)

      assert existing_semester == Repo.get(Semester, existing_semester.id)
    end
  end

  describe "delete_semester/1" do

    test "success: it deletes the semester" do

      semester = Factory.insert(:semester)

      assert {:ok, _deleted_semester} = Semesters.delete_semester(semester)

      refute Repo.get(Semester, semester.id)
    end
  end

  describe "get_active_semester!/0" do
    test "success: returns the currently active semester" do

      semester1 = Factory.insert(:semester)
      semester2 = Factory.insert(:semester)

      params = %{"is_active" => true}
      {:ok, updated} = Semesters.update_semester(semester1, params)

      assert retrieved = Semesters.get_active_semester!()
      assert retrieved == updated
      refute retrieved == semester2
    end
  end
end
