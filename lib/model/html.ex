defmodule GenDSL.Model.Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)

    # {name, table, fields, flags} # TODO: Check values with changeset for valid datatypes in fields
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:command, :string, default: "html")

    # TODO: check XOR schema/no_schema with constraints
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  # TODO: revise list when a method to XOR fields is introduced
  @remainder_fields ~w[context web no_context no_schema context_app]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end
