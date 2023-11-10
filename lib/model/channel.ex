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
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => channel, "callback" => task}
  end

  def execute(channel) do
    specs = []

    specs
    |> Mix.Tasks.Phx.Gen.Channel.run()
  end
end
