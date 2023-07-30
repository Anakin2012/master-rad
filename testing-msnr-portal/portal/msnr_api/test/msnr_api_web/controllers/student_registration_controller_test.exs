defmodule MsnrApiWeb.StudentRegistrationControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.StudentRegistrationsFixtures
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @create_attrs %{
    "email" => "pana.petrovic@gmail.com",
    "first_name" => "ana",
    "index_number" => "12344",
    "last_name" => "petrovic"
  }
  @update_attrs %{
    "email" => "pana.petrovic@gmail.com",
    "first_name" => "ana",
    "index_number" => "12345",
    "last_name" => "new last name",
    "status" => :accepted
  }
  @invalid_attrs %{"status" => nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create student_registration" do
    test "renders student_registration when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.student_registration_path(conn, :create),
          student_registration: @create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.student_registration_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "pana.petrovic@gmail.com",
               "first_name" => "ana",
               "index_number" => "12344",
               "last_name" => "petrovic"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.student_registration_path(conn, :create),
          student_registration: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show student registration" do
    setup [:create_student_registration]
    test "renders student registration when id is valid", %{conn: conn, student_registration: student_registration} do

      conn = get(conn, Routes.student_registration_path(conn, :show, student_registration))

      assert %{
          "email" => "johdoe@gmail.com",
          "first_name" => "John",
          "index_number" => "1234",
          "last_name" => "Doe"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "delete student_registration" do
    setup [:create_student_registration]

    test "deletes chosen student_registration", %{
      conn: conn,
      student_registration: student_registration
    } do
      conn = delete(conn, Routes.student_registration_path(conn, :delete, student_registration))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.student_registration_path(conn, :show, student_registration))
      end
    end
  end

  defp create_student_registration(_) do
    student_registration = student_registration_fixture()
    %{student_registration: student_registration}
  end
end
