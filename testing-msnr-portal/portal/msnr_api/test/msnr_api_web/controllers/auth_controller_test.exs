defmodule MsnrApiWeb.AuthControllerTest do
  use MsnrApiWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end



end
