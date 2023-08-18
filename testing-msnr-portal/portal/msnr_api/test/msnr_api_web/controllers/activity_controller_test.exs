defmodule MsnrApiWeb.ActivityControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.ActivitiesFixtures
  import MsnrApi.UserFixtures
  import MsnrApi.SemestersFixtures
  import MsnrApi.ActivityTypesFixtures
  alias MsnrApi.Activities.Activity
  alias MsnrApi.Semesters.Semester
  alias MsnrApi.ActivityTypes.ActivityType

  @create_attrs %{
    end_date: 42,
    is_signup: true,
    start_date: 42
  }
  @update_attrs %{
    end_date: 43,
    is_signup: false,
    start_date: 43
  }
  @invalid_attrs %{end_date: nil, is_signup: nil, start_date: nil}

  setup %{conn: conn} do
    user_params = %{
      email: "profemail",
      first_name: "john",
      last_name: "doe",
      password: "test",
      role: :professor
    }

    %{professor: professor} = create_professor()
    authenticated_conn = assign(conn, :user_info, %{role: :professor})

    {:ok, conn: authenticated_conn}
   # {:ok, conn: put_req_header(authenticated_conn, "accept", "application/json")}
  end



  describe "create activity" do
    setup [:create_semester]
    test "renders activity when data is valid", %{conn: conn, semester: semester} do

      %{activity_type: activity_type} = create_activity_type()
      conn = post(conn, Routes.activity_path(conn, :create), activity: %{activity_type_id: activity_type.id,
                                                                               end_date: 1712016000,
                                                                               is_signup: true,
                                                                               start_date: 1692230400,
                                                                               semester_id: semester.id})

      assert %{"id" => id} = json_response(conn, 201)["data"]

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
