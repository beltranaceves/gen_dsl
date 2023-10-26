defmodule Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Release" do
    field(:docker, :boolean)
    field(:no_ecto, :boolean)
    field(:ecto, :boolean)
    field(:command, :string, default: "release")
  end

  @required_fields ~w[]a
  @optional_fields ~w[docker no_ecto ecto]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end
