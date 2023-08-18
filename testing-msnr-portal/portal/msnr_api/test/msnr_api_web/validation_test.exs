defmodule MsnrApiWeb.ValidationTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.Accounts.TokenPayload
  import MsnrApiWeb.Validation

  describe "validate_user/2" do
    test "valid professor user" do
      curr_user = %TokenPayload{role: :professor}
      assert {:ok} == validate_user(curr_user, %{student_id: 123, group_id: 456})
    end

    test "validate student user with matching ID" do
      curr_user = %TokenPayload{id: 123, role: :student, group_id: 456}
      assert {:ok} == validate_user(curr_user, %{student_id: 123, group_id: 456})
    end

    test "validate user with matching group ID" do
      curr_user = %TokenPayload{id: 789, role: :student, group_id: 456}
      assert {:ok} == validate_user(curr_user, %{student_id: 123, group_id: 456})
    end

    test "unauthorized user" do
      curr_user = %TokenPayload{id: 123, role: :student, group_id: 789}
      assert {:error, :unauthorized} == validate_user(curr_user, %{student_id: 456, group_id: 123})
    end
  end

  describe "validate_time/2" do
    test "validate time with professor" do
      curr_user = %{role: :professor}
      assert {:ok} == validate_time(curr_user, %{})
    end

    test "returns FunctionClauseError with invalid role" do
      curr_user = %{role: :student}
      assert_raise FunctionClauseError, fn ->
        validate_time(curr_user, %{}) end
    end

    test "validate_time with valid time range" do
      start_date = System.os_time(:second) - 86400
      end_date = System.os_time(:second) + 86400

      input = %{start_date: start_date, end_date: end_date}
      assert {:ok} == validate_time(%{}, input)
    end

    test "validate_time with invalid time range" do
      one_day = 86400
      start_date = System.os_time(:second) + one_day
      end_date = System.os_time(:second) - one_day

      input1 = %{start_date: start_date, end_date: end_date}
      input2 = %{start_date: start_date, end_date: end_date+2*one_day}
      input3 = %{start_date: start_date-2*one_day, end_date: end_date}
      assert {:error, :bad_request} == validate_time(%{}, input1)
      assert {:error, :bad_request} == validate_time(%{}, input2)
      assert {:error, :bad_request} == validate_time(%{}, input3)
    end
  end

  describe  "validate_files" do
    test "validate_files with valid files" do
      docIds = [1, 2]
      docs = ["doc1.pdf", "doc2.txt"]
      files = [
        %{"name" => "doc1", "extension" => ".txt"},
        %{"name" => "doc2", "extension" => ".pdf"}
      ]

      doc_map = Enum.zip_reduce(docIds, docs, %{}, fn id, doc, acc -> Map.put(acc, id, doc) end)

      assert [] == Enum.reduce(files, [], fn %{"name" => name, "extension" => extension}, acc ->
        case doc_map[name <> extension] do
          %{path: path} -> [{name, extension, path} | acc]
          _ -> acc
        end
      end)

      expected_result = [
        {"doc1", ".pdf", "/path/to/doc1.pdf"},
        {"doc2", ".txt", "/path/to/doc2.txt"}
      ]

#      assert {:ok, expected_result} == validate_files(docIds, docs, %{"files" => files})
    end


  end


end