defmodule MsnrApi.Queries.AccountsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Accounts, Accounts.User, Semesters,Students, Students.Student, StudentRegistrations.StudentRegistration}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    {:ok, active_semester} = Semesters.update_semester(semester, params)
  end

  describe "get_user_info" do
    test "gets professor info" do
      {:ok, semester} = setup_semester()
      params = Factory.string_params_for(:user)
               |> Map.put("role", :professor)

      {:ok, %User{} = user} = Accounts.create_user(params)
      user_from_db = Accounts.get_user!(user.id)

      result = Accounts.get_user_info(email: user.email)
      assert result.user == user_from_db
      assert result.semester_id == semester.id
      assert result.student_info.index_number == nil
      assert result.student_info.group_id == nil
    end

    test "gets student info" do
      {:ok, semester} = setup_semester()
      params = Factory.string_params_for(:user)

      {:ok, %User{} = user} = Accounts.create_user(params)
      {:ok, %Student{} = student} = Students.create_student(user, %{"index_number" => "122345"})

      user_from_db = Accounts.get_user!(user.id)

      result = Accounts.get_user_info(email: user.email)
      assert result.user == user_from_db
      assert result.semester_id == semester.id
      assert result.student_info.index_number == student.index_number
      assert result.student_info.group_id == nil
    end

    test "returns nil if no record" do
      assert nil == Accounts.get_user_info(email: "allala")
    end
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

  describe "create_user/1" do
    test "success: it inserts a user in the db and returns the user" do

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
    test "success: it inserts a student account in the db when given student registration and returns the student" do

      setup_semester()
      student_registration = Factory.insert(:student_registration)

      assert {:ok, %User{} = returned_user} = Accounts.create_student_account(student_registration)

      user_from_db = Repo.get(User, returned_user.id)
      assert returned_user == user_from_db
      assert returned_user.role == :student

      assert user_from_db.inserted_at == user_from_db.updated_at
    end

    test "error: returns an error tuple when student account can't be created" do
      #missing params
      student_registration = %StudentRegistration{}
      assert {:error, %Changeset{valid?: false}} = Accounts.create_student_account(student_registration)
    end

  end

  describe "get_user/1" do

    test "success: it returns a user when given a valid id" do
      existing_user = Factory.insert(:user)

      assert returned_user = Accounts.get_user!(existing_user.id)

      assert returned_user == existing_user
    end

    test "error: it returns an Ecto.NoResultsError when a user doesn't exist" do

      invalid_id = -1
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

  describe "set_password/2" do
    test "success: updates the password field in database" do
      existing_user = Factory.insert(:user)
      password = "pass123"

      assert {:ok, returned_user} = Accounts.set_password(existing_user, password)

      assert returned_user.password == password
      user_from_db = Accounts.get_user!(existing_user.id)

      assert user_from_db.hashed_password == returned_user.hashed_password
      assert user_from_db.password == nil
    end

    test "error: cant set a password if it is too short" do
      existing_user = Factory.insert(:user)
      invalid_password = "123"

      assert {:error, %Changeset{}} = Accounts.set_password(existing_user, invalid_password)

      assert existing_user == Accounts.get_user!(existing_user.id)
    end

    test "error: cant set a password if it is not a string" do
      existing_user = Factory.insert(:user)
      invalid_password = DateTime.utc_now()

      assert {:error, %Changeset{}} = Accounts.set_password(existing_user, invalid_password)

      assert existing_user == Accounts.get_user!(existing_user.id)
    end
  end

  describe "verify_user/1 with email and password url path" do
    test "success: returns an authorized user" do
      existing_user = Factory.insert(:user)
      params = %{email: existing_user.email,
                 uuid: existing_user.password_url_path}

      assert {:ok, user} = Accounts.verify_user(params)
      assert user == existing_user
    end

    test "error: returns an error tuple when user can't be authorized" do
      params = %{email: "user@email",
                 uuid: Ecto.UUID.generate()}

      assert {:error, :unauthorized} = Accounts.verify_user(params)
    end
  end

  describe "verify_user/1 with id and refresh token" do
    test "success: returns an authorized user with professor role" do
      setup_semester()
      params = Factory.string_params_for(:user)
               |> Map.put("role", :professor)

      assert {:ok, %User{} = professor} = Accounts.create_user(params)

      params = %{id: professor.id,
                 refresh_token: professor.refresh_token}

      assert {:ok, user_info} = Accounts.verify_user(params)
    end

    test "success: returns an authorized user with student role" do
      setup_semester()

      params = Factory.string_params_for(:user)
               |> Map.put("role", :student)

      assert {:ok, %User{} = student} = Accounts.create_user(params)


    end

    test "error: returns an error tuple when user can't be authorized" do
      params = %{id: -1,
                 refresh_token: Ecto.UUID.generate()}

      assert {:error, :unauthorized} = Accounts.verify_user(params)
    end
  end


end
