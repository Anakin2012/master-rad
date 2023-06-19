defmodule MsnrApi.Queries.SemestersTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Students, Students.Student, Students.StudentSemester, Semesters}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_students/1" do

  end

  describe "get_student/1" do

  end

  describe "create_student/2" do

  end

  describe "update_student/2" do

  end

  describe "delete_student/1" do
    test "success: it deletes the student" do
      user = Factory.insert(:user)
      semester = Factory.insert(:semester)

      params = %{"is_active" => true}
      {:ok, active_semester} = Semesters.update_semester(semester, params)

      params = Factory.string_params_for(:student)
               |> Map.put("user_id", user.id)

      {:ok, student} = Students.create_student(user, params)

      assert {:ok, _deleted_student} = Students.delete_student(student)

      refute Repo.get(Student, student.id)
    end
  end

end
