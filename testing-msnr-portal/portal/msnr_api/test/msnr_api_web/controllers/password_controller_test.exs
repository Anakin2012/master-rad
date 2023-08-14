defmodule MsnrApiWeb.PasswordControllerTest do
  use MsnrApiWeb.ConnCase
  import MsnrApi.UserFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "update - set password" do
    setup [:create_user]
    test "verifies and sets the password", %{conn: conn, user: user} do
      params = %{"email" => user.email,
                 "password" => "newpass"}

      conn = put(conn, Routes.password_path(conn, :update, user.password_url_path), params)
      assert response(conn, 204)
    end

    test "error: unauthorized user calls fallback controller and returns 401", %{conn: conn, user: user} do
      invalid_params = %{"email" => "other",
                         "password" => "new"}
      conn = put(conn, Routes.password_path(conn, :update, user.password_url_path), invalid_params)
      assert json_response(conn, 401)["{\"errors\":{\"detail\":\"Unauthorized\"}}"] != %{}
    end
  end


  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
