defmodule MsnrApi.Schema.StudentRegistrationTest do
  use ExUnit.Case
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @expected_fields_with_types [
    {:id, :id},
    {:email, :string},
    {:first_name, :string},
    {:last_name, :string},
    {:index_number, :string},
    {:status, {:parameterized, Ecto.Enum,
      %{
        mappings: [
        accepted: "accepted",
        rejected: "rejected",
        pending: "pending"
        ],
        on_cast: %{
        "accepted" => :accepted,
        "pending" => :pending,
        "rejected" => :rejected
        },
        on_dump: %{
        accepted: "accepted",
        pending: "pending",
        rejected: "rejected"
        },
        on_load: %{
        "accepted" => :accepted,
        "pending" => :pending,
        "rejected" => :rejected
        },
        type: :string
      }}
    },
    {:semester_id, :id},
    {:inserted_at, :naive_datetime},
    {:updated_at, :naive_datetime}
  ]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- StudentRegistration.__schema__(:fields) do
          type = StudentRegistration.__schema__(:type, field)
          {field, type}
        end

        assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_fields_with_types)
    end
  end

end
