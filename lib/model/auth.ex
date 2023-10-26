defmodule GenDSL.Model.Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Auth" do
    field(:context, :string)
    field(:web, :string)
    # TODO: check valid input
    field(:hashing_lib, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "auth")
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web hashing_lib]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end
