defmodule MsnrApi.Plugs.TokenAuthenticationTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApiWeb.Plugs.TokenAuthentication
  import MsnrApi.UserFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
