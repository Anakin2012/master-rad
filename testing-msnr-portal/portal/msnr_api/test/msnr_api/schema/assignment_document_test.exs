defmodule MsnrApi.Schema.AssignmentDocumentTest do
  use ExUnit.Case
  alias MsnrApi.Assignments.AssignmentDocument

  @expected_fields_with_types [
    {:assignment_id, :id},
    {:document_id, :id},
    {:attached, :boolean},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- AssignmentDocument.__schema__(:fields) do
          type = AssignmentDocument.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
