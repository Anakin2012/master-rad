defmodule MsnrApi.Queries.GroupsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Groups, Groups.Group}
  alias Ecto.Changeset
  alias MsnrApi.Semesters

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  defp setup_semester() do
    semester = Factory.insert(:semester)

    params = %{"is_active" => true}
    {:ok, active_semester} = Semesters.update_semester(semester, params)
  end


  describe "list_groups/1" do
    test "success: lists all groups for given semester id" do
      {:ok, active_semester} = setup_semester()

      assert [] == Groups.list_groups(active_semester.id)
    end

    test "success: lists all groups for given semester id" do
      {:ok, active_semester} = setup_semester()

      assert [] == Groups.list_groups(active_semester.id)
    end

  end

  describe "get_group/1" do
    test "success: it returns a semester when given a valid id" do


    end
  end

end
