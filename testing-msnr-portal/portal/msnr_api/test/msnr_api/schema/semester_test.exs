defmodule MsnrApi.Schema.SemesterTest do
  use ExUnit.Case
  alias MsnrApi.Semesters.Semester

  @expected_fields_with_types [
    {:id, :id},
    {:year, :integer},
    {:is_active, :boolean},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Semester.__schema__(:fields) do
          type = Semester.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
