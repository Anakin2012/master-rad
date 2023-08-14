defmodule MsnrApiWeb.DocumentControllerTest do
  use MsnrApiWeb.ConnCase

  import MsnrApi.DocumentsFixtures

  alias MsnrApi.Documents.Document
  alias MsnrApi.Assingments.AssignmentDocument

  @create_attrs %{
    "file_name" => "some file_name",
    "file_path" => "some file_path"
  }
  @update_attrs %{
    "file_name" => "some updated file_name",
    "file_path" => "some updated file_path"
  }
  @invalid_attrs %{"file_name" => nil, "file_path" => nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all documents"

    end
  end

  defp create_document(_) do
    document = document_fixture()
    %{document: document}
  end
end
