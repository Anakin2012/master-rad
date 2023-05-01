defmodule MsnrApi.Schema.StudentTest do
  use MsnrApi.Support.SchemaCase
  alias MsnrApi.Students.Student
  alias MsnrApi.Accounts.User
  alias MsnrApi.Semesters.Semester

  @required_fields [
    {:index_number, :string}
  ]

  @optional_fields [
    :user_id, :inserted_at, :updated_at
  ]

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

  describe "changeset/2" do


  end
end
