defmodule GenDSL.Model.Socket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Socket" do
    field(:module, :string)
    field(:command, :string, default: "socket")
  end

  @required_fields ~w[module]a
  @optional_fields ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end
