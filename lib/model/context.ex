defmodule GenDSL.Model.Context do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Context" do
    field(:context, :string)
    field(:no_schema, :boolean)
    field(:merge_with_existing_context, :boolean)
    field(:no_merge_with_existing_context, :boolean)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "context")
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web no_context no_schema merge_with_existing_context no_merge_with_existing_context]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end
