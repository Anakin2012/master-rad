defmodule MsnrApi.Queries.DocumentsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Documents, Documents.Document, Accounts, Semesters, ActivityTypes, Activities, Students}
  alias MsnrApi.{Assignments.AssignmentDocument, Assignments.Assignment, Topics, Groups, Groups.Group}
  alias Ecto.Changeset
  alias MsnrApi.Accounts.TokenPayload

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_documents/1" do
    test "success: lists all documents when given assignment id" do
      assignment = Factory.insert(:assignment)
      document = Factory.insert(:document)

      params = Factory.string_params_for(:assignment_document)
               |> Map.put("assignment_id", assignment.id)
               |> Map.put("document_id", document.id)

      {:ok, assignment_document} =  %AssignmentDocument{}
                                    |> AssignmentDocument.changeset(params)
                                    |> Repo.insert()

      result = Documents.list_documents(%{"assignment_id" => assignment.id}) |> Enum.at(0)

      assert result.attached == assignment_document.attached
      assert result.id == document.id
      assert result.file_name == document.file_name
    end

    test "returns empty list when no documents or nonexistant assignment" do
      assignment = Factory.insert(:assignment)
      assert [] == Documents.list_documents(%{"assignment_id" => assignment.id})

      assert [] == Documents.list_documents(%{"assignment_id" => -1})
    end

    test "error: cast error when wrong argument" do
      assert_raise Ecto.Query.CastError, fn ->
        Documents.list_documents(%{"assignment_id" => DateTime.utc_now()}) end
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

  describe "create_document/1 with tokenpayload" do
    test "creates a document for assignment and current user" do
      {:ok, semester} = setup_semester()
      params_at = Factory.string_params_for(:activity_type)
                  |> Map.put("is_group", false)
                  |> Map.put("code", "cv")
                  |> Map.put("name", "CV")

      {:ok, activity_type} = ActivityTypes.create_activity_type(params_at)
      params_prof = Factory.string_params_for(:user)
                    |> Map.put("role", :professor)

      {:ok, user} = Accounts.create_user(params_prof)
      params_student = Factory.string_params_for(:student)
                       |> Map.put("user", user)

      {:ok, student} = Students.create_student(user, params_student)
      params = Factory.string_params_for(:activity)
                 |> Map.put("semester_id", semester.id)
                 |> Map.put("activity_type_id", activity_type.id)
                 |> Map.put("is_signup", false)
                 |> Map.put("end_date", System.os_time(:second)+100000)


      {:ok, activity} = Activities.create_activity(Integer.to_string(semester.id), params)
      assignment_id = Enum.map(Repo.all(Assignment), fn(x) -> x.id end)
                      |> Enum.at(0)

      user_info = Accounts.get_user_info(id: user.id)
      token_payload = TokenPayload.from_user_info(%{user: user, student_info: user_info.student_info, semester_id: semester.id})

      {:ok, document} = Documents.create_document(assignment_id, %{filename: "naslov",
                                                            path: "/Users/panap/files"},
                                                            token_payload)
      document_from_db = Repo.get(Document, document.id)

      assert document_from_db == document

      assignmentDoc = Repo.all(MsnrApi.Assignments.AssignmentDocument)
                      |> Enum.at(0)

      assert document.id == assignmentDoc.document_id
      assert assignment_id == assignmentDoc.assignment_id
      assert assignmentDoc.attached == true
    end

    test "error: invalid params" do
      user = Factory.insert(:user)
      assert_raise FunctionClauseError, fn -> Documents.create_document(-1, %{filename: "naslov",
                                             path: "/Users/panap/files"},
                                             user) end
    end

    test "error: invalid path" do
      #TODO
    end
  end

  describe "create_documents/3" do
    test "success: creates documents" do
      {:ok, semester} = setup_semester()
      params_at = Factory.string_params_for(:activity_type)
                  |> Map.put("is_group", false)
                  |> Map.put("code", "v1")
                  |> Map.put("name", "Prva verzija")

      {:ok, activity_type} = ActivityTypes.create_activity_type(params_at)

      params_prof = Factory.string_params_for(:user)
                    |> Map.put("role", :student)

      {:ok, user} = Accounts.create_user(params_prof)
      params_student = Factory.string_params_for(:student)
                       |> Map.put("user", user)

      {:ok, student} = Students.create_student(user, params_student)
      params = Factory.string_params_for(:activity)
                 |> Map.put("semester_id", semester.id)
                 |> Map.put("activity_type_id", activity_type.id)
                 |> Map.put("is_signup", false)
                 |> Map.put("end_date", System.os_time(:second)+100000)


      {:ok, activity} = Activities.create_activity(Integer.to_string(semester.id), params)

      assignment_id = Enum.map(Repo.all(Assignment), fn(x) -> x.id end)
                      |> Enum.at(0)

      extended = %{
        assignment: Repo.get(Assignment, assignment_id),
        semester_year: semester.year,
        start_date: activity.start_date,
        end_date: activity.end_date,
        content: activity_type.content,
        name: activity_type.name
      }

      user_info = Accounts.get_user_info(id: user.id)
      token_payload = TokenPayload.from_user_info(%{user: user, student_info: user_info.student_info, semester_id: semester.id})

      file_tuples = [%{"name" => "file1", "extension" => ".txt", "path" => "/path/to/file1.txt"}]
      assert [] == Documents.create_documents(file_tuples, extended, token_payload)
      assert true
      # TODO !!!

      #assignment = Documents.get_assignment_extended@!()
    end
  end

  describe "filename_infix/1" do
    test "success: when student and not group, return student name" do
      {student, user} = activity_setup(false, ActivityTypes.TypeCode.cv())

      assert "#{user.first_name}#{user.last_name}" == Documents.filename_infix(%{student_id: student.user_id, group_id: nil})
    end

    test "success: when group and not student, return topic" do
      {:ok, group} = activity_setup(true, ActivityTypes.TypeCode.group())
      %{students: students, topic: topic} = Groups.get_group!(group.id)
      last_names =
        students
        |> Enum.map(& &1.user.last_name)
        |> Enum.join()

      title = topic.title
            |> String.split()
            |> Enum.map(&String.capitalize/1)
            |> Enum.join()

      assert "01_#{last_names}_#{title}" == Documents.filename_infix(%{student_id: nil, group_id: group.id})
    end

    test "when both nil, raise Argument error" do
      assert_raise ArgumentError, fn ->
        Documents.filename_infix(%{student_id: nil, group_id: nil}) end
    end

    test "when invalid student, raise NoResultsError" do

      assert_raise Ecto.NoResultsError, fn ->
        Documents.filename_infix(%{student_id: -1, group_id: nil}) end
    end

    test "when invalid group, raise Match error" do
      assert_raise MatchError, fn ->
        Documents.filename_infix(%{student_id: nil, group_id: -1}) end
    end

    test "when both given, raise FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        Documents.filename_infix(%{student_id: -1, group_id: -1}) end
    end

  end

  defp activity_setup(is_group, code) do
    {:ok, active_semester} = setup_semester()
    #activity_type = Factory.insert(:activity_type)
    params_at = Factory.string_params_for(:activity_type)
                |> Map.put("is_group", is_group)
                |> Map.put("code", code)

    {:ok, activity_type} = ActivityTypes.create_activity_type(params_at)

    user = Factory.insert(:user)
    params_student = Factory.string_params_for(:student)
                     |> Map.put("user", user)

    {:ok, student} = Students.create_student(user, params_student)
    params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", active_semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("end_date", System.os_time(:second)+100000)


    {:ok, activity} = Activities.create_activity(Integer.to_string(active_semester.id), params)


    user2 = Factory.insert(:user)

    params_student2 = Factory.string_params_for(:student)
                     |> Map.put("user", user2)

    {:ok, student2} = Students.create_student(user2, params_student2)

    if is_group == true do
      setup_group(active_semester.id, [student.user_id, student2.user_id])
    else
      {student, user}
    end


  end

  defp setup_group(semester_id, students) do
    {:ok, topic} = setup_topic()
    {:ok, group} = Groups.create_group(%{semester_id: semester_id, students: students})
    {:ok, updated} = group
                     |> Group.changeset(%{"topic_id" => topic.id})
                     |> Repo.update()

    {:ok, updated}
  end

  defp setup_topic() do
    params_topic = Factory.string_params_for(:topic)
    {:ok, topic} = Topics.create_topic(params_topic)
  end


  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end

end
