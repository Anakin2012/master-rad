defmodule MsnrApi.Plugs.TokenAuthenticationTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApiWeb.Plugs.TokenAuthentication
  import MsnrApi.UserFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "call/2" do
    setup [:create_user]

    test "assigns user_info when a valid token is provided", %{conn: conn} do
      token = "valid_access_token"
      conn_with_token = put_req_header(conn, "authorization", "Bearer #{token}")
      expected_payload = %{first_name: "john", last_name: "doe", role: :student}

      conn_with_user_info = conn_with_token
        |> TokenAuthentication.call([])

      assert conn_with_user_info.assigns[:user_info] == expected_payload
    end

  end


  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
