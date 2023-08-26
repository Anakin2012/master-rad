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






end
