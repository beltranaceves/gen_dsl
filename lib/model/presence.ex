defmodule GenDSL.Model.Presence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Presence" do
    field(:module, :string, default: "Presence")

    field(:command, :string, default: "presence")
  end

  @required_fields ~w[]a
  @optional_fields ~w[module]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    presence =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => presence, "callback" => task}
  end

  def execute(presence) do
    specs = []

    specs
    |> Mix.Tasks.Phx.Gen.Presence.run()
  end
end
