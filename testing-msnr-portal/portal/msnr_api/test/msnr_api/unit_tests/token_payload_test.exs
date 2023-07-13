defmodule TokenPayloadTest do
  use ExUnit.Case
  alias MsnrApi.Accounts.TokenPayload
  alias MsnrApi.Accounts.User

  describe "from_user_info/1" do
    test "success: returns the correct token payload" do
      user = %User{id: 1, role: "student"}
      st_info = %{group_id: 3}
      semester_id = 2

      expected_payload = %TokenPayload{
        id: 1,
        role: "student",
        group_id: 3,
        semester_id: 2
      }

      actual_payload = TokenPayload.from_user_info(%{
        user: user, student_info: st_info, semester_id: semester_id
      })

      assert actual_payload == expected_payload
    end
  end

end
