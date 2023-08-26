defmodule MsnrApiWeb.ActivityControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApiWeb.Plugs.Authorization
  import MsnrApi.ActivitiesFixtures
  import MsnrApi.UserFixtures
  import MsnrApi.SemestersFixtures
  import MsnrApi.ActivityTypesFixtures

  setup %{conn: conn} do
    conn =
      build_conn()
      |> put_req_header("authorization",
                        "Bearer " <> MsnrApiWeb.get_env(:msnr_api_web,
                        MsnrApiWeb.Endpoint)[:api_key])
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
   #{:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "create activity" do
    setup [:create_semester]
    test "authorization error when no role", %{conn: conn, semester: semester} do

      %{activity_type: activity_type} = create_activity_type()
      conn = post(conn, Routes.activity_path(conn, :create), activity: %{activity_type_id: activity_type.id,
                                                                               end_date: 1712016000,
                                                                               is_signup: true,
                                                                               start_date: 1692230400,
                                                                               semester_id: semester.id})

      assert conn.resp_body == "Unauthorized"
      assert conn.status == 401
    end
  end

  defp create_professor() do
    professor = user_professor_fixture()
    %{professor: professor}
  end

  defp create_activity(_) do
    activity = activity_fixture()
    %{activity: activity}
  end

  defp create_activity_type() do
    activity_type =  activity_type_fixture()
    %{activity_type: activity_type}
  end

  defp create_semester(_) do
    semester = semester_fixture()
    %{semester: semester}
  end
end
