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

  def to_task(params) do
    socket =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => socket, "callback" => task}
  end

  def execute(socket) do
    specs = []

    Mix.Task.run(socket.command, specs)
  end
end
