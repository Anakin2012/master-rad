defmodule MsnrApi.Schema.StudentRegistrationTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias MsnrApi.StudentRegistrations.StudentRegistration

  @required_fields [
    :status
  ]

  @optional_fields [
    :id, :email, :first_name, :index_number, :last_name, :semester_id, :inserted_at, :updated_at
  ]

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

  describe "changeset/2" do

    test "success: returns a valid changeset when given valid arguments" do
      valid_params = %{
        "status" => :accepted
      }
      changeset = StudentRegistration.changeset(%StudentRegistration{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset

      for field <- @required_fields do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]
        assert actual == expected,
          "Values did not match for: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end
    end

    test "error: returns an invalid changeset when given uncastable values" do
      invalid_params = %{
        "status" => NaiveDateTime.local_now()
      }

      assert %Changeset{valid?: false, errors: errors} = StudentRegistration.changeset(%StudentRegistration{}, invalid_params)

      assert errors[:status], "the field :status is misssing from errors."
      {_, meta} = errors[:status]
      assert meta[:validation] == :cast,
      "The validation type #{meta[:validaiton]} is incorrect."
    end

    test "error: returns an error changeset when default fields are missing" do
      params = %{}

      assert %Changeset{valid?: true, changes: changes} = StudentRegistration.changeset(%StudentRegistration{}, params)

      refute changes[:status], "The default field :status is not default when it should be."
    end

  end
end
