defmodule MsnrApi.Schema.AssignmentTest do
  use ExUnit.Case
  alias MsnrApi.Assignments.Assignment

  @expected_fields_with_types [
    {:id, :id},
    {:grade, :integer},
    {:comment, :string},
    {:completed, :boolean},
    {:student_id, :id},
    {:group_id, :id},
    {:activity_id, :id},
    {:related_topic_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Assignment.__schema__(:fields) do
          type = Assignment.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
