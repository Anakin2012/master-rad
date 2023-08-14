defmodule MsnrApi.Schema.StudentTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Students.Student
  alias MsnrApi.Accounts.User
  alias MsnrApi.Semesters.Semester
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @required_fields [
    {:index_number, :string}
  ]

  @required_user_fields [
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:role, :string}
  ]

  @student_registration_fields [
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:index_number, :string}
  ]

  @required_semester_fields [
    {:year, :integer},
    {:is_active, :boolean}
  ]

  @expected_fields_with_types [
    {:user_id, :integer},
    {:index_number, :string},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Student.__schema__(:fields) do
          type = Student.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

  describe "changeset/2" do
    setup do
      Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
    end

    test "success: returns a valid changeset when given valid arguments" do

      {:ok, existing_user} = insert_user()
      {:ok, existing_semester} = insert_semester()

      valid_params = valid_params(@required_fields)
      changeset = Student.changeset(existing_user, Map.put(valid_params, "semesters", existing_semester))

      assert %Changeset{valid?: true, changes: changes} = changeset

      for {field, _} <- @required_fields do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an invalid changeset when given uncastable values" do
      {:ok, existing_user} = insert_user()
      {:ok, existing_semester} = insert_semester()

      invalid_params = invalid_params(@required_fields)

      assert %Changeset{valid?: false, errors: errors} =
        Student.changeset(existing_user, Map.put(invalid_params, "semesters", existing_semester))

      assert errors[:index_number], "the field index_number is missing from errors."

      {_, meta} = errors[:index_number]
      assert meta[:validation] == :cast,
          "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      {:ok, existing_user} = insert_user()
      {:ok, existing_semester} = insert_semester()

      assert %Changeset{valid?: false, errors: errors} =
        Student.changeset(existing_user, Map.put(params, "semesters", existing_semester))

      assert errors[:index_number], "The field :index_number is missing from errors."

      {_, meta} = errors[:index_number]

      assert meta[:validation] == :required,
       "The validation type #{meta[:validation]} is incorrect."
    end

    test "error: returns an error changeset when reusing index number" do
      {:ok, existing_student_registration} = insert_student_registration()
      {:ok, existing_user} = insert_user(existing_student_registration)
      {:ok, existing_semester} = insert_semester()

      valid_params = valid_params(@required_fields)
                     |> Map.put("index_number", existing_student_registration.index_number)


      changeset = Student.changeset(existing_user,
                                    Map.put(valid_params, "semesters", existing_semester))

      {:ok, existing_student} = MsnrApi.Repo.insert(changeset)

      changeset_with_reused_index_number = Student.changeset(existing_user,
                                                            Map.put(valid_params, "students", existing_student))

      assert {:error, %Changeset{valid?: false, errors: errors}} = MsnrApi.Repo.insert(changeset_with_reused_index_number)

      assert errors[:index_number], "The field :index_number is missing from errors."

      {_, meta} = errors[:index_number]

      assert meta[:constraint] == :unique,
        "The validation type is incorrect."
    end


   # test "unique constraint for index_number" do
@moduledoc """
      params = valid_params(@required_fields)

      params_sr = valid_params(@student_registration_fields)
      params_sr = Map.put(params_sr, "status", :accepted)

      {:ok, existing_sr} =
        %StudentRegistration{}
        |> StudentRegistration.changeset_insert(params_sr)
        |> MsnrApi.Repo.insert()

      {:ok, existing_user} =
        %User{}
        |> User.changeset(existing_sr)
        |> MsnrApi.Repo.insert()


      {:ok, existing_semester} =
        %Semester{}
        |> Semester.changeset(valid_params(@required_semester_fields))
        |> MsnrApi.Repo.insert()

      {:ok, existing_student} =
        %Student{}
        |> Student.changeset(existing_user, params
                                            |> Map.put("semesters", existing_semester))
        |> MsnrApi.Repo.insert()

      changeset_with_reused_index_number =
        %Student{}
        |> Student.changeset(existing_user, params
                                            |> Map.put("index_number", existing_student.index_number))

      assert {:error, %Changeset{valid?: false, errors: errors}} =
        MsnrApi.Repo.insert(changeset_with_reused_index_number)

      assert errors[:index_number], "The field :index_number is missing from errors."

      {_, meta} = errors[:index_number]

      assert meta[:constraint] == :unique,
        "The validation type  is incorrect."
"""
  #  end

  end

  defp insert_student_registration() do
    {:ok, _student_registration} =
        %StudentRegistration{}
        |> StudentRegistration.changeset_insert(valid_params(@student_registration_fields))
        |> MsnrApi.Repo.insert()
  end

  defp insert_user(student_registration) do

    params = %{"email" => student_registration.email,
               "first_name" => student_registration.first_name,
               "last_name" => student_registration.last_name,
               "index_number" => student_registration.index_number
              }

    {:ok, _user} =
      %User{}
      |> User.changeset(student_registration)
      |> MsnrApi.Repo.insert()
  end

  defp insert_user() do
    {:ok, _user} =
      %User{}
      |> User.changeset(valid_params(@required_user_fields))
      |> MsnrApi.Repo.insert()
  end

  defp insert_semester() do
    {:ok, _semester} =
      %Semester{}
      |> Semester.changeset(valid_params(@required_semester_fields))
      |> MsnrApi.Repo.insert()
  end



end
