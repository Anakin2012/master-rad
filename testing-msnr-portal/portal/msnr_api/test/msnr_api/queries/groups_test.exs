defmodule MsnrApi.Queries.GroupsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Groups, Groups.Group}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  def list_groups(semester_id) do
    from(g in Group,
      join: ss in StudentSemester,
      on: ss.semester_id == ^semester_id and g.id == ss.group_id,
      join: s in Student,
      on: s.user_id == ss.student_id,
      join: u in assoc(s, :user),
      left_join: t in assoc(g, :topic),
      preload: [topic: t, students: {s, user: u}],
      select: g
    )
    |> Repo.all()
  end

  describe "list_groups/1" do
    test "success: lists all groups for given semester id" do
      semester = Factory.insert(:semester)

    end
  end

  describe "get_group/1" do
    test "success: it returns a semester when given a valid id" do
      semester = Factory.insert(:semester, "is_active" => true)
      topic = Factory.insert(:topic)
      {:ok, group} =
        %Group{}
        |> Group.changeset(%{"topic_id" => topic.id})
        |> MsnrApi.Repo.insert()

      {:ok, student_semester1} =
        %StudentSemester{}
          |> StudentSemester.changeset(%{"student_id" => student1.user_id, "semester_id" => active_semester.id, "student" => student1})
          |> MsnrApi.Repo.insert()

    end
  end

end
