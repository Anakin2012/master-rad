defmodule MsnrApi.Queries.GroupsTest do

  use MsnrApi.Support.DataCase
  alias MsnrApi.{Groups, Groups.Group}
  alias Ecto.Changeset

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(MsnrApi.Repo)
  end

  describe "list_groups/1" do
    test "success: lists all groups for given semester id" do


    end

  end

end
