defmodule MsnrApi.Queries.AccountsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Accounts, Accounts.User}
  alias Ecto.Changeset
  import MsnrApi.Support.Factory

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "create_user/1" do

    test "success: it inserts a user in the db and returns the user" do
      # ovo nalazi account_factory funkciju
      # dobijamo parametre sa string key values
      params = Factory.string_params_for(:user)

      assert {:ok, %User{} = returned_user} = Accounts.create_user(params)

      user_from_db = Repo.get(User, returned_user.id)
      assert returned_user == user_from_db

      for {field, expected} <- params do
        schema_field = String.to_existing_atom(field)
        actual = Map.get(user_from_db, schema_field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert user_from_db.inserted_at == user_from_db.updated_at
    end

    test "error: returns an error tuple when user can't be created" do
      missing_params = %{}

      assert {:error, %Changeset{valid?: false}} = Accounts.create_user(missing_params)
    end
  end


  describe "create_student_account/1" do


  end


  describe "list_users/0" do

    test "success: returns a list of all users" do
      existing_users = [
        Factory.insert(:user),
        Factory.insert(:user),
        Factory.insert(:user)
      ]

      assert retrieved_users = Accounts.list_users()

      assert retrieved_users == existing_users
    end

    test "success: returns an empty list when no users" do
      {:ok, _} = Ecto.Adapters.SQL.query(MsnrApi.Repo, "DELETE FROM users")

      assert [] == Accounts.list_users()
    end
  end

  describe "get_user/1" do

    test "success: it returns a user when given a valid id" do
      existing_user = Factory.insert(:user)

      assert returned_user = Accounts.get_user!(existing_user.id)

      assert returned_user == existing_user
    end

    test "error: it returns an error tuple when a user doesn't exist" do

      invalid_id = Enum.random(5000..6000)
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(invalid_id) end

    end
  end

  describe "update_user/2" do

    test "success: it updates database and returns the user" do

      existing_user = Factory.insert(:user)

      params = Factory.string_params_for(:user)
        |> Map.take(["first_name"])

      assert {:ok, returned_user} = Accounts.update_user(existing_user, params)

      user_from_db = Repo.get(User, returned_user.id)
      assert returned_user == user_from_db

      expected_user_data = existing_user
        |> Map.from_struct()
        |> Map.drop([:__meta__, :updated_at])
        |> Map.put(:first_name, params["first_name"])

      for {field, expected} <- expected_user_data do
        actual = Map.get(user_from_db, field)

        assert actual == expected,
          "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      # refute user_from_db.updated_at == existing_user.updated_at
      # assert %DateTime{} = user_from_db.updated_at
    end

    test "error: returns an error tuple when user can't be updated" do

      existing_user = Factory.insert(:user)

      bad_params = %{"first_name" => DateTime.utc_now()}

      assert {:error, %Changeset{}} = Accounts.update_user(existing_user, bad_params)

      assert existing_user == Repo.get(User, existing_user.id)
    end
  end

  describe "delete_user/1" do

    test "success: it deletes the user" do

      user = Factory.insert(:user)

      assert {:ok, _deleted_user} = Accounts.delete_user(user)

      refute Repo.get(User, user.id)
    end

  end

end
