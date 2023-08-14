defmodule MsnrApi.Queries.SemestersTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Students, Students.Student, Students.StudentSemester, Semesters, Semesters.Semester, Accounts, Accounts.User}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    {:ok, active_semester} = Semesters.update_semester(semester, params)
  end

  describe "list_students/1" do
    test "success: returns a list of all students" do

      {:ok, active_semester} = setup_semester()

      user1 = Factory.insert(:user)
      user2 = Factory.insert(:user)

      student1 = Factory.insert(:student, user_id: user1.id, semesters: [active_semester], user: user1)
      student2 = Factory.insert(:student, user_id: user2.id, semesters: [active_semester], user: user2)

      {:ok, student_semester1} =
        %StudentSemester{}
          |> StudentSemester.changeset(%{"student_id" => student1.user_id, "semester_id" => active_semester.id, "student" => student1})
          |> MsnrApi.Repo.insert()

      {:ok, student_semester2} =
        %StudentSemester{}
          |> StudentSemester.changeset(%{"student_id" => student2.user_id, "semester_id" => active_semester.id, "student" => student2})
          |> MsnrApi.Repo.insert()

      students = [student_semester1 |> Map.from_struct()
                                    |> Map.drop([:student]),
                  student_semester2 |> Map.from_struct()
                                    |> Map.drop([:student])]

      assert retrieved_students = Students.list_students(active_semester.id)

      f = hd(retrieved_students)
          |> Map.from_struct()
          |> Map.drop([:student])

      s = List.last(retrieved_students)
          |> Map.from_struct()
          |> Map.drop([:student])

      assert [f, s] == students
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

  describe "update_student/2" do
    test "updates a field" do
      {:ok, active_semester} = setup_semester()

      user1 = Factory.insert(:user)
      student1 = Factory.insert(:student, user_id: user1.id, semesters: [active_semester], user: user1)


#      user = Factory.insert(:user)
      params = Factory.string_params_for(:student)
               |> Map.put(:semesters, active_semester)

 #     assert {:ok, %User{} = updated_user} = Accounts.update_user(user, params)
  #    assert {:ok, %Student{} = returned_student} = Students.create_student(user, params)

      assert {:ok, returned_student1} = Students.update_student(user1, params)

      student_from_db = Repo.get(Student, user1.id)
      assert returned_student1.id == student_from_db.user_id

      expected_user_data = user1
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:index_number, params["index_number"])

      for {field, expected} <- expected_user_data do
        actual = Map.get(student_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end
  end

  describe "delete_student/1" do
    test "success: it deletes the student" do
      user = Factory.insert(:user)

      student = Factory.insert(:student, user_id: user.id, user: user)
      assert {:ok, _deleted_student} = Students.delete_student(student)

      refute Repo.get(Student, student.user_id)
    end
  end

end
