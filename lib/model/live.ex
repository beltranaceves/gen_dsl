defmodule GenDSL.Model.Live do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Live" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:command, :string, default: "live")
  end

  @required_fields ~w[]a
  @optional_fields ~w[context web no_context no_schema context_app]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.changeset/1)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    live =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => live, "callback" => task}
  end

  def execute(live) do
    specs = []

    Mix.Task.run(live.command, specs)
  end
end
