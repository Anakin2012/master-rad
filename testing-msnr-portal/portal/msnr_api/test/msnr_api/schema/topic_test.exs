defmodule MsnrApi.Schema.TopicTest do
  use ExUnit.Case
  alias MsnrApi.Topics.Topic

  @expected_fields_with_types [
    {:id, :id},
    {:title, :string},
    {:number, :integer},
    {:semester_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Topic.__schema__(:fields) do
          type = Topic.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
