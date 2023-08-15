defmodule MsnrApi.Queries.AssignmentsTest do

  use MsnrApi.Support.DataCase
  alias Protocol.UndefinedError
  alias MsnrApi.{Semesters, Assignments, Assignments.Assignment, Activities}
  alias Ecto.Changeset
  alias MsnrApi.Students

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end

  describe "list_assignments/1 returns activity, activity type, and some assignment fields" do
    test "success: lists assignments for student in semester" do
      {:ok, active_semester} = setup_semester()
      activity_type = Factory.insert(:activity_type)
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)

      {:ok, student} = Students.create_student(user, params_student)

      params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)

      {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)

      resultList = Assignments.list_assignments(%{"student_id" => student.user_id, "semester_id" => active_semester.id})
      resultAssignment = Enum.at(resultList, 0)

      assert resultAssignment.activity == activity
      assert resultAssignment.activity_type == activity_type
    end

    test "success: empty list when no assignments" do
      {:ok, semester} = setup_semester()
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)

      {:ok, student} = Students.create_student(user, params_student)
      assert [] == Assignments.list_assignments(%{"student_id" => student.user_id, "semester_id" => semester.id})

      assert [] = Assignments.list_assignments(%{"student_id" => -1, "semester_id" => -1})
    end

    test "error: wrong argument raises Cast error" do
      assert_raise Ecto.Query.CastError, fn ->
        Assignments.list_assignments(%{"student_id" => DateTime.utc_now(), "semester_id" => DateTime.utc_now()}) end
    end

  end


  describe "list_assignments/1 for semester" do
    test "success: it lists all the assignments for a semester" do
      {:ok, active_semester} = setup_semester()
      activity_type = Factory.insert(:activity_type)
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)

      {:ok, student} = Students.create_student(user, params_student)

      params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("is_group", false)

      {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)

      resultList = Assignments.list_assignments(%{"semester_id" => active_semester.id})
      resultAssignment = Enum.at(resultList, 0)
     # expectedAssignment = Assignments.get_assignment!(resultAssignment.id)

      assert resultAssignment.activity_id == activity.id
      assert resultAssignment.student_id == student.user_id
    end

    test "success: empty list when no assignments or non existant semester" do
      {:ok, semester} = setup_semester()
      assert [] == Assignments.list_assignments(%{"semester_id" => semester.id})

      assert [] = Assignments.list_assignments(%{"semester_id" => -1})
    end

    test "error: wrong argument raises Cast error" do
      assert_raise Ecto.Query.CastError, fn ->
        Assignments.list_assignments(%{"semester_id" => DateTime.utc_now()}) end
    end
  end

  describe "get_assignment_extended!/1" do
    test "success: returns info about assignment" do
      {:ok, active_semester} = setup_semester()
      activity_type = Factory.insert(:activity_type)
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)
      {:ok, student} = Students.create_student(user, params_student)

      params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("is_group", false)

      {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)
      resultList = Assignments.list_assignments(%{"semester_id" => active_semester.id})
      assignment = Enum.at(resultList, 0)

      result = Assignments.get_assignment_extended!(assignment.id)

      assert result.assignment == assignment
      assert result.semester_year == active_semester.year
      assert result.name == activity_type.name
    end

    test "returns nothing if no assignment" do
      assert_raise Ecto.NoResultsError, fn ->
        Assignments.get_assignment_extended!(-1) end
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

  describe "get_signup/1" do
    test "success: returns {:ok, signup} if assignment is signup activity" do
      {:ok, active_semester} = setup_semester()
      activity_type = Factory.insert(:activity_type)
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)
      {:ok, student} = Students.create_student(user, params_student)

      params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", true)
               |> Map.put("is_group", false)

      {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)
      resultList = Assignments.list_assignments(%{"semester_id" => active_semester.id})
      assignment = Enum.at(resultList, 0)

      assert {:ok, assignment} == Assignments.get_signup(assignment.id)
    end

    test "success: returns {:error, not_found} if assignment is not a signup activity" do
      {:ok, active_semester} = setup_semester()
      activity_type = Factory.insert(:activity_type)
      user = Factory.insert(:user)
      params_student = Factory.string_params_for(:student)
      {:ok, student} = Students.create_student(user, params_student)

      params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("is_group", false)

      {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)
      resultList = Assignments.list_assignments(%{"semester_id" => active_semester.id})
      assignment = Enum.at(resultList, 0)

      assert {:error, :not_found} == Assignments.get_signup(assignment.id)
    end

    test "cast error case" do
      assert_raise Ecto.Query.CastError, fn ->
        Assignments.get_signup(DateTime.utc_now()) end
    end
  end

  describe "update_signup/2" do
    test "success: updates the completed field" do

      assignment = Factory.insert(:assignment)
      {:ok, updated} = Assignments.update_signup(assignment, true)

      assert updated.completed == true
    end

    test "success: if false, stays false" do
      assignment = Factory.insert(:assignment)
      {:ok, updated} = Assignments.update_signup(assignment, false)

      assert updated.completed == false
    end

    test "error: bad argument gives cast error" do
      assignment = Factory.insert(:assignment)

      assert {:error, %Changeset{valid?: false, errors: errors}} = Assignments.update_signup(assignment, "string")
      assert errors[:completed], "the field completed is missing from errors."

      {_, meta} = errors[:completed]
      assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
    end
  end

end
