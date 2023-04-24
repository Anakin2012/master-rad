defmodule MsnrApi.Schema.ActivityTest do
  use ExUnit.Case
  alias MsnrApi.Activities.Activity

  @expected_fields_with_types [
    {:id, :id},
    {:start_date, :integer},
    {:end_date, :integer},
    {:points, :integer},
    {:is_signup, :boolean},
    {:semester_id, :id},
    {:activity_type_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Activity.__schema__(:fields) do
          type = Activity.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
