defmodule MsnrApi.Queries.StudentRegistrationsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Semesters, Accounts, Students.Student, StudentRegistrations, StudentRegistrations.StudentRegistration}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end

  describe "list_student_registrations/1" do

    test "success: returns a list of student registrations in given semester" do
      setup_semester()

      existing1 = Factory.insert(:student_registration)
      existing2 = Factory.insert(:student_registration)

      actual = StudentRegistrations.list_student_registrations(existing1.semester_id)
      assert [existing1, existing2] == actual
    end

    test "success: returns an empty list when no student registrations in active semester" do
      {:ok, active_semester} = setup_semester()

      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM student_registrations")

      assert [] == StudentRegistrations.list_student_registrations(active_semester.id)
    end

    test "success: returns an empty list when given invalid semester id" do
      assert [] == StudentRegistrations.list_student_registrations(-1)
    end
  end

  describe "get_student_registration!/1" do

    test "success: it returns a student registration when given a valid id" do
      setup_semester()
      existing_student_registration = Factory.insert(:student_registration)

      assert returned_student_registration = StudentRegistrations.get_student_registration!(existing_student_registration.id)

      assert returned_student_registration == existing_student_registration
    end

    test "error: it returns an error tuple when a student registration doesn't exist" do

      invalid_id = -1
      assert_raise Ecto.NoResultsError, fn ->
        StudentRegistrations.get_student_registration!(invalid_id) end
    end
  end

  describe "create_student_registration/1" do
    test "success: it inserts a student registration in the db and returns the student registration" do

      setup_semester()
      params = Factory.string_params_for(:student_registration)

      assert {:ok, %StudentRegistration{} = returned_student_registration} = StudentRegistrations.create_student_registration(params)

      actual = returned_student_registration |> Map.from_struct()
                                             |> Map.drop([:semester])

      student_registration_from_db = Repo.get(StudentRegistration, returned_student_registration.id)
                                    |> Map.from_struct()
                                    |> Map.drop([:semester])

      assert actual == student_registration_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(student_registration_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert student_registration_from_db.inserted_at == student_registration_from_db.updated_at
    end

    test "error: returns an error tuple when student registration can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = StudentRegistrations.create_student_registration(missing_params)
    end
  end

  describe "update_student_registration" do
    test "status accepted update creates user, student, and sends mail" do
      {:ok, _} = setup_semester()
      sr = Factory.insert(:student_registration)

      assert {:ok, multi} = StudentRegistrations.update_student_registration(sr, %{"status" => "accepted"})

      user_from_db = Accounts.list_users() |> Enum.at(0)
      student_from_db = Repo.all(Student) |> Enum.at(0)


      assert {user_from_db.id} == {multi.user.id}
      assert multi.user.role == :student
      assert {student_from_db.user_id, student_from_db.index_number} == {multi.student.user_id, multi.student.index_number}
      assert {sr.id, :accepted} == {multi.student_registration.id, multi.student_registration.status}
      assert multi.email == %{}
    end

    test "status rejected sets status to rejected and sends mail" do
      {:ok, _} = setup_semester()
      sr = Factory.insert(:student_registration)

      assert {:ok, multi} = StudentRegistrations.update_student_registration(sr, %{"status" => "rejected"})
      assert multi.email == %{}
      assert multi.student_registration.status == :rejected
      assert multi.student_registration.id == sr.id
    end

    test "error: wrong attributes raise FunctionClauseError" do
      {:ok, _} = setup_semester()
      sr = Factory.insert(:student_registration)

      assert_raise FunctionClauseError, fn ->
        StudentRegistrations.update_student_registration(sr, %{}) end
    end
  end

  describe "delete_student_registration/1" do

    test "success: it deletes the student_registration" do
      setup_semester()
      student_registration = Factory.insert(:student_registration)

      assert {:ok, _deleted_student_registration} = StudentRegistrations.delete_student_registration(student_registration)

      refute Repo.get(StudentRegistration, student_registration.id)
    end
  end

end
