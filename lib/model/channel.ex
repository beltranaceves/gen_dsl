defmodule GenDSL.Model.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Channel" do
    field(:module, :string)
    field(:command, :string, default: "channel")
  end

  @required_fields ~w[module]a
  @optional_fields ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    channel =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => channel, "callback" => task}
  end

  def execute(channel) do
    specs = []

    Mix.Task.run(channel.command, specs)
  end
end
