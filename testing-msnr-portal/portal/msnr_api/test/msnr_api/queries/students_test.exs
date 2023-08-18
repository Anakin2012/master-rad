defmodule MsnrApi.Queries.StudentsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Students, Students.Student, Students.StudentSemester, Semesters}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end

  describe "list_students/1" do
    test "success: returns a list of all students" do

      {:ok, active_semester} = setup_semester()

      user1 = Factory.insert(:user)
      user2 = Factory.insert(:user)

      student1 = Factory.insert(:student, user_id: user1.id, semesters: [active_semester], user: user1)
      student2 = Factory.insert(:student, user_id: user2.id, semesters: [active_semester], user: user2)

      student_list = Enum.map(Students.list_students(active_semester.id), fn(x) -> x.student end)

      just_students = Enum.map(student_list, fn(x) -> Map.drop(x, [:semesters, :user]) end)
      just_students_expected = Enum.map([student1, student2], fn(x) -> Map.drop(x, [:semesters, :user]) end)
      assert just_students_expected == just_students

    end

    test "empty when no students" do
      {:ok, active_semester} = setup_semester()
      assert [] = Students.list_students(active_semester.id)
    end
  end

  describe "get_student/1" do
    test "success: returns one student on given id" do
      setup_semester()

      user = Factory.insert(:user)
      student = Factory.insert(:student, user_id: user.id, user: user)

      assert returned_student = Students.get_student!(student.user_id)
      assert returned_student == student
    end

    test "error: it returns an error tuple when a student doesn't exist" do

      invalid_id = -1
      assert_raise Ecto.NoResultsError, fn ->
        Students.get_student!(invalid_id) end
    end
  end

  describe "create_student/2" do
    test "success: it inserts a student in the db and returns the student" do

      setup_semester()
      user = Factory.insert(:user)
      params = Factory.string_params_for(:student)

      assert {:ok, %Student{} = returned_student} = Students.create_student(user, params)

      student_from_db = Repo.get(Student, returned_student.user_id)
      assert returned_student
            |> Map.from_struct()
            |> Map.drop([:semesters]) == student_from_db |> Map.from_struct() |> Map.drop([:semesters])

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(student_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert student_from_db.inserted_at == student_from_db.updated_at
    end

    test "error: returns an error tuple when student can't be created" do
      user = Factory.insert(:user)
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Students.create_student(user, missing_params)
    end
  end

  ## update_student is never used

  describe "delete_student/1" do
    test "success: it deletes the student" do
      user = Factory.insert(:user)

      student = Factory.insert(:student, user_id: user.id, user: user)
      assert {:ok, _deleted_student} = Students.delete_student(student)

      refute Repo.get(Student, student.user_id)
    end
  end

end
