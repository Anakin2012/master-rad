defmodule MsnrApiWeb.SemesterControllerTest do
  use MsnrApiWeb.ConnCase

  alias MsnrApi.Semesters.Semester
  alias MsnrApiWeb.SemesterController

  describe "GET /api/semesters" do
    test "index returns a list of semesters" do
      # Arrange
      expected_semesters = [
        %{"name" => "Spring 2023"},
        %{"name" => "Summer 2023"},
        %{"name" => "Fall 2023"}
      ]

      # Configure the mock behavior
      SemestersMock
      |> stub(:list_semester, fn -> expected_semesters end)

      # Act
      conn = conn(:get, "/")
      response = MyController.index(conn, %{})

      # Assert
      assert conn.status == 200
      assert response.view == "index.json"
      assert response.assigns[:semester] == expected_semesters
    end
  end
end
