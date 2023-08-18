defmodule MsnrApi.ActivityTypesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.ActivityTypes` context.
  """

  @doc """
  Generate a activity_type.
  """
  def activity_type_fixture(attrs \\ %{}) do
    {:ok, activity_type} =
      attrs
      |> Enum.into(%{
       name: "Grupe",
       code: "group",
       description: "desc",
       has_signup: false,
       is_group: false,
       content: %{}
      })
      |> MsnrApi.ActivityTypes.create_activity_type()

    activity_type
  end
end
