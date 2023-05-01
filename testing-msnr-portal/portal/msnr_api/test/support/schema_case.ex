defmodule MsnrApi.Support.SchemaCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Ecto.Changeset
      import MsnrApi.Support.SchemaCase
    end
  end

  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(MsnrApi.Repo, :manual)
  end

  def valid_params(fields_with_types) do

    valid_value_by_type = %{
      string: fn -> Faker.Lorem.word() end,
      naive_datetime: fn -> Faker.NaiveDateTime.backward(Enum.random(0..100)) end,
      id: fn -> Enum.random(0..100) end,
      integer: fn -> Enum.random(0..5000) end,
      boolean: fn -> true end,
      map: fn -> %{
        files: [{"V1", extension: ".pdf"}]
      } end
    }

    for {field, type} <- fields_with_types, into: %{} do
      case field do
        :role -> {Atom.to_string(field), :student}
        _ -> {Atom.to_string(field), valid_value_by_type[type].()}
      end
    end
  end

  def invalid_params(fields_with_types) do
    invalid_value_by_type = %{
      string: fn -> DateTime.utc_now() end,
      naive_datetime: fn -> Faker.Lorem.word() end,
      id: fn -> DateTime.utc_now() end,
      integer: fn -> DateTime.utc_now() end,
      boolean: fn -> DateTime.utc_now() end,
      map: fn -> Faker.Lorem.word() end
    }

    for {field, type} <- fields_with_types, into: %{} do
      {Atom.to_string(field), invalid_value_by_type[type].()}
    end
  end
end
