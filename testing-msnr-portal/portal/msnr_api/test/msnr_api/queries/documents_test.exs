defmodule MsnrApi.Queries.DocumentsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Documents, Documents.Document}
  alias MsnrApi.Assignments.AssignmentDocument
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_documents/1" do
    test "success: lists all documents when given assignment id" do

    end
  end

  describe "get_document/1" do

    test "success: it returns a document when given a valid id" do
      existing_document = Factory.insert(:document)

      assert returned_document = Documents.get_document!(existing_document.id)
      assert returned_document == existing_document
    end

    test "error: it returns an error tuple when document doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Documents.get_document!(-1) end
    end
  end

  describe "create_document/1" do

    test "success: it inserts a document in the db and returns the document" do

      user = Factory.insert(:user)
      params = Factory.string_params_for(:document)
               |> Map.put("creator_id", user.id)

      assert {:ok, %Document{} = returned_document} = Documents.create_document(params)

      document_from_db = Repo.get(Document, returned_document.id)
      assert returned_document == document_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(document_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert document_from_db.inserted_at == document_from_db.updated_at
    end

    test "error: returns an error tuple when document can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Documents.create_document(missing_params)
    end
  end

  describe "update_document/2" do

    test "success: it updates database and returns the document" do

      existing_user = Factory.insert(:user)

      valid_params = %{
        "file_name" => "name",
        "file_path" => "path"
      }

      {:ok, existing_document} =
        %Document{}
        |> Document.changeset(Map.put(valid_params, "creator_id", existing_user.id))
        |> MsnrApi.Repo.insert()


      params = Factory.string_params_for(:document)
        |> Map.take(["file_name"])

      assert {:ok, returned_document} = Documents.update_document(existing_document, params)

      document_from_db = Repo.get(Document, returned_document.id)
      assert returned_document == document_from_db

      expected_document_data = existing_document
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:file_name, params["file_name"])

      for {field, expected} <- expected_document_data do
        actual = Map.get(document_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an error tuple when document can't be updated" do

      existing_document = Factory.insert(:document)

      bad_params = %{"file_name" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Documents.update_document(existing_document, bad_params)

      assert existing_document == Repo.get(Document, existing_document.id)
    end
  end

  describe "delete_document/1" do
    test "success: it deletes the document" do

      document = Factory.insert(:document)

      assert {:ok, _deleted_document} = Documents.delete_document(document)

      refute Repo.get(Document, document.id)
    end
  end
end
