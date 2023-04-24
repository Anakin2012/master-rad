defmodule MsnrApi.Schema.DocumentTest do
  use ExUnit.Case
  alias MsnrApi.Documents.Document

  @expected_fields_with_types [
    {:id, :id},
    {:file_name, :string},
    {:file_path, :string},
    {:creator_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Document.__schema__(:fields) do
          type = Document.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
