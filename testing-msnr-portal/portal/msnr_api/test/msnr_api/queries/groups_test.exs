defmodule MsnrApi.Queries.GroupsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Groups, Groups.Group}
  alias MsnrApi.{Students, Activities, ActivityTypes, Topics}
  alias MsnrApi.Semesters

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    Semesters.update_semester(semester, params)
  end


  describe "list_groups/1" do
    test "success: empty list when no groups" do
      {:ok, active_semester} = setup_semester()

      assert [] == Groups.list_groups(active_semester.id)
    end

    test "list groups in semester" do
      {:ok, semester} = setup_semester()
      {students, group} = setup_group(semester)
      returned_group = Groups.list_groups(semester.id)
                      |> Enum.at(0)

      group_from_db = Repo.get(Group, group.id)

      assert group_from_db.id == returned_group.id

      expected_student1_data = students |> Enum.at(0)
                               |> Map.drop([:semesters, :user])
      expected_student2_data = students |> Enum.at(1)
                               |> Map.drop([:semesters, :user])

      returned_student1_data = returned_group.students
                               |> Enum.at(0)
                               |> Map.drop([:semesters, :user])
      returned_student2_data = returned_group.students
                               |> Enum.at(1)
                               |> Map.drop([:semesters, :user])


      assert MapSet.new([expected_student1_data, expected_student2_data]) ==
             MapSet.new([returned_student1_data, returned_student2_data])
    end
  end

  describe "get_group!/1" do
    test "success: it returns group with topic and students by id" do
      {:ok, semester} = setup_semester()
      {students, group} = setup_group(semester)

      params_topic = Factory.string_params_for(:topic)
      {:ok, topic} = Topics.create_topic(params_topic)

      {:ok, group} = group
                     |> Group.changeset(%{"topic_id" => topic.id})
                     |> Repo.update()

      returned_group = Groups.get_group!(group.id)
      assert {:ok, returned_group2} = Groups.get_group(group.id)
      assert returned_group == returned_group2

      students = Enum.map(students, fn(x) -> {x.index_number, x.user_id} end)
      returned_students = Enum.map(returned_group.students, fn(x) -> {x.index_number, x.user_id} end)

      assert students == returned_students
      assert group.id == returned_group.id
      assert topic == returned_group.topic
    end

    test "error: returns nil when no group" do
      assert nil == Groups.get_group!(-1)
    end

    test "error: get_group/1 function returns error tuple" do
      assert {:error, :not_found} == Groups.get_group(-1)
    end
  end

  describe "create_group/1" do
    test "success: creates a group and inserts in database, updates assignment" do
      {:ok, semester} = setup_semester()

      {_, created_group} = setup_group(semester)

      group_from_db = Repo.get(Group, created_group.id)

      assert group_from_db == created_group
    end

    test "error: returns error tuple when invalid" do
      {:ok, semester} = setup_semester()

      assert {:error, :bad_request} == Groups.create_group(%{semester_id: semester.id, students: []})
    end

  end

  describe "update_group/2" do
    test "success: updates group with topic" do
      {:ok, semester} = setup_semester()
      {_, group} = setup_group(semester)

      {:ok, topic} = setup_topic(semester)
      {:ok, returned_group} = Groups.update_group(group, %{"topic_id" => topic.id})
      assert topic.id == returned_group.topic_id
      refute group.topic_id == returned_group.topic_id
      assert group.id == returned_group.id
    end

    test "success: returns error tuple when cant be updated" do
      {:ok, semester} = setup_semester()
      {_, group} = setup_group(semester)

      assert {:error, :bad_request} = Groups.update_group(group, %{"topic_id" => 0})
    end
  end

  describe "delete_group/1" do
    test "deletes the group" do
      # never used,
      # needs different implementation for deleting group
    end
  end

  defp setup_topic(semester) do
    at_params = Factory.string_params_for(:activity_type)
                |> Map.put("code", "topic")
                |> Map.put("is_group", true)
                |> Map.put("name", "Odabir teme")

    {:ok, activity_type} = ActivityTypes.create_activity_type(at_params)
    params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("is_group", true)
               |> Map.put("end_date", System.os_time(:second)+100000)

    {:ok, _} = Activities.create_activity(Integer.to_string(semester.id), params)

    params_topic = Factory.string_params_for(:topic)
    Topics.create_topic(params_topic)
  end

  defp setup_group(semester) do

    user1 = Factory.insert(:user)
    user2 = Factory.insert(:user)
   # user3 = Factory.insert(:user)

    {:ok, student1} = Students.create_student(user1, %{"index_number" => "12345"})
    {:ok, student2} = Students.create_student(user2, %{"index_number" => "12346"})
   # {:ok, student3} = Students.create_student(user3, %{"index_number" => "12347"})

    at_params = Factory.string_params_for(:activity_type)
                |> Map.put("code", "group")
                |> Map.put("is_group", true)
                |> Map.put("name", "Prijava grupe")

    {:ok, activity_type} = ActivityTypes.create_activity_type(at_params)
    params = Factory.string_params_for(:activity)
               |> Map.put("semester_id", semester.id)
               |> Map.put("activity_type_id", activity_type.id)
               |> Map.put("is_signup", false)
               |> Map.put("is_group", true)
               |> Map.put("end_date", System.os_time(:second)+100000)

    {:ok, _} = Activities.create_activity(Integer.to_string(semester.id), params)

    {:ok, group} = Groups.create_group(%{semester_id: semester.id, students: [student1.user_id, student2.user_id]})
    #, student3.user_id]})

    {[student1, student2], group}
    #, student3], group}
  end


end
