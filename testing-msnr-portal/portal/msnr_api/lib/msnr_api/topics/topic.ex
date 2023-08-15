defmodule MsnrApi.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :number, :integer
    belongs_to :semester, MsnrApi.Semesters.Semester
    has_one :group, MsnrApi.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :semester_id])
    |> validate_required([:title, :semester_id])
    |> apply_set_number()
  end

  defp apply_set_number(changeset) do
    semester_id = get_change(changeset, :semester_id)

    case semester_id do
      nil ->
        changeset
      _ ->
        changeset
        |> set_number()
    end
  end

  defp set_number(changeset) do
    changeset
    |> put_change(:number, MsnrApi.Topics.next_topic_number(get_change(changeset, :semester_id)))
  end

end
