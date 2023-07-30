defmodule MsnrApi.StudentRegistrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MsnrApi.StudentRegistrations` context.
  """

  @doc """
  Generate a student_registration.
  """
  def student_registration_fixture(attrs \\ %{}) do
    {:ok, student_registration} =
      attrs
      |> Enum.into(%{
        email: "johdoe@gmail.com",
        first_name: "John",
        index_number: "1234",
        last_name: "Doe"
      })
      |> MsnrApi.StudentRegistrations.create_student_registration()

    student_registration
  end
end
