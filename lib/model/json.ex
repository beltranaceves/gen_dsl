defmodule Json do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Json" do
    field(:context, :string)
    field(:api_prefix, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end
