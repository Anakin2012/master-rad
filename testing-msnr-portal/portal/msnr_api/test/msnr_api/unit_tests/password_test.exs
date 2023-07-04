defmodule MsnrApi.UnitTests.PasswordTest do
  alias MsnrApi.Accounts.Password
  use ExUnit.Case

  describe "verify password" do
    test "success: verifies the password by hashing" do
      password = "somepass123"

      assert hash = Password.hash(password)
      assert Password.verify_with_hash(password, hash) == true
    end

    test "error: returns false when given wrong password" do
      password = "somepass123"
      wrong = "wrong"

      assert hash = Password.hash(password)
      refute Password.verify_with_hash(wrong, hash)
    end
  end
end
