defmodule MsnrApiWeb.StudentControllerTest do
  use MsnrApiWeb.ConnCase
  import MsnrApi.SemestersFixtures
  import MsnrApi.UserFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "list students", %{conn: conn} do

      %{semester: semester} = create_semester()
      {:ok, student} = create_user()

      conn = get(conn, Routes.semester_student_path(conn, :index, semester.id))
      assert json_response(conn, 200)["data"] ==
      [
        %{
          "email" => "some email",
          "first_name" => "john",
          "group_id" => nil,
          "id" => student.user_id,
          "index_number" => "123455",
          "last_name" => "doe"
         }
      ]
    end

    test "list is empty", %{conn: conn} do
      %{semester: semester} = create_semester()
      conn = get(conn, Routes.semester_student_path(conn, :index, semester.id))
      assert json_response(conn, 200)["data"] == []
    end

  end

  # show isnt used

  defp create_semester() do
    semester = semester_fixture()
    %{semester: semester}
  end

  defp create_user() do
    user = user_fixture()
    {:ok, _} = MsnrApi.Students.create_student(user, %{"index_number" => "123455"})
  end

end
