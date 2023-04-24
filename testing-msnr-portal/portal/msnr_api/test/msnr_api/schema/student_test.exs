defmodule MsnrApi.Schema.StudentTest do
  use ExUnit.Case
  alias MsnrApi.Students.Student

  @expected_fields_with_types [
    {:user_id, :integer},
    {:index_number, :string},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Student.__schema__(:fields) do
          type = Student.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
