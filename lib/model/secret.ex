defmodule GenDSL.Model.Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field(:length, :integer, default: 32)
    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[length]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end
