defmodule MsnrApi.Schema.ActivityTypeTest do
  use ExUnit.Case
  alias MsnrApi.ActivityTypes.ActivityType

  @expected_fields_with_types [
    {:id, :id},
    {:name, :string},
    {:code, :string},
    {:description, :string},
    {:has_signup, :boolean},
    {:is_group, :boolean},
    {:content, :map},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- ActivityType.__schema__(:fields) do
          type = ActivityType.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
