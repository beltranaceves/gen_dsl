defmodule GenDSL.Model.Embededd do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Embededd" do
    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)
    field(:command, :string, default: "embededd")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.changeset/1)
    |> validate_required(@required_fields)
  end

def to_task(params) do
    embedded =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => embedded, "callback" => task}
  end

  def execute(embedded) do
    specs = []

    Mix.Task.run(embedded.command, specs)
  end
end
