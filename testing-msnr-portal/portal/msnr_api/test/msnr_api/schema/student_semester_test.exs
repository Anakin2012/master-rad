defmodule MsnrApi.Schema.StudentSemesterTest do
  use ExUnit.Case
  alias MsnrApi.Students.StudentSemester

  @expected_fields_with_types [
    {:student_id, :id},
    {:semester_id, :id},
    {:group_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- StudentSemester.__schema__(:fields) do
          type = StudentSemester.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
