defmodule MsnrApi.Schema.UserTest do
  use ExUnit.Case
  alias MsnrApi.Accounts.User

  @expected_fields_with_types [
    {:id, :id},
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:hashed_password, :string},
    {:password_url_path, Ecto.UUID},
    {:refresh_token, Ecto.UUID},
    {:role, {:parameterized, Ecto.Enum,
    %{
      mappings: [
        student: "student",
        professor: "professor"
      ],
      on_cast: %{
        "professor" => :professor,
        "student" => :student
      },
      on_dump: %{
        professor: "professor",
        student: "student"
      },
      on_load: %{
        "professor" => :professor,
        "student" => :student
      },
      type: :string
      }}
    },
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
