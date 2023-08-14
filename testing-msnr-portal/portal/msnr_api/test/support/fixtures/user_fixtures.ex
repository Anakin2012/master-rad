defmodule MsnrApi.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        first_name: "john",
        last_name: "doe",
        role: :student
      })
      |> MsnrApi.Accounts.create_user()

    user
  end
end
