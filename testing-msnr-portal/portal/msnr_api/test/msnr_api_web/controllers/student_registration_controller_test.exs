defmodule MsnrApiWeb.StudentRegistrationControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.StudentRegistrations
  import MsnrApi.SemestersFixtures

  @create_attrs %{
    "email" => "pana.petrovic@gmail.com",
    "first_name" => "ana",
    "index_number" => "12344",
    "last_name" => "petrovic"
  }

  @invalid_attrs %{"status" => nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "list all registrations" do
    setup [:create_student_registration]
    test "renders all registrations in given semester", %{conn: conn, student_registration: _student_registration} do

      conn = get(conn, Routes.semester_student_registration_path(conn, :index, 1))
      assert json_response(conn, 200)["data"] == []
    end
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

  describe "updates student registration status" do
    setup [:create_semester, :create_student_registration]
    test "success: accepts student registrations", %{conn: conn, student_registration: student_registration} do
      conn = put(conn, Routes.student_registration_path(conn, :update, student_registration.id),
       %{"student_registration" => %{"status" => "accepted"}}
      )

      response_map =%{ "email" => "pana.petrovic@gmail.com",
                        "first_name" => "ana",
                        "index_number" => "12344",
                        "last_name" => "petrovic",
                        "status" => "accepted"
                      }
                      |> Map.put("id", student_registration.id)


      assert response_map == json_response(conn, 200)["data"]
    end

    test "success: rejects student registrations", %{conn: conn, student_registration: student_registration} do
      conn = put(conn, Routes.student_registration_path(conn, :update, student_registration.id),
       %{"student_registration" => %{"status" => "rejected"}}
      )

      response_map =%{ "email" => "pana.petrovic@gmail.com",
                        "first_name" => "ana",
                        "index_number" => "12344",
                        "last_name" => "petrovic",
                        "status" => "rejected"
                      }
                      |> Map.put("id", student_registration.id)


      assert response_map == json_response(conn, 200)["data"]
    end



  end

  describe "show student registration" do
    setup [:create_student_registration]
    test "renders student registration when id is valid", %{conn: conn, student_registration: student_registration} do

      conn = get(conn, Routes.student_registration_path(conn, :show, student_registration))


      response_map =%{ "email" => "pana.petrovic@gmail.com",
                        "first_name" => "ana",
                        "index_number" => "12344",
                        "last_name" => "petrovic",
                        "status" => "pending"
                      }
                      |> Map.put("id", student_registration.id)


      assert response_map == json_response(conn, 200)["data"]
    end

    test "cant render", %{conn: conn, student_registration: student_registration
    } do

      {response, _, _} = assert_error_sent 404, fn ->
        get(conn, Routes.student_registration_path(conn, :show, -1))
      end

      assert 404 == response
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
    {:ok, student_registration} = StudentRegistrations.create_student_registration(@create_attrs)
    %{student_registration: student_registration}
  end

  defp create_semester(_) do
    semester = semester_fixture()
    %{semester: semester}
  end
end
