defmodule GenDSL.Model.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Channel" do
    field(:module, :string)
    field(:command, :string, default: "channel")
  end

  @required_fields ~w[module]a
  @optional_fields ~w[]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[module]a

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

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_channel] =
      GenDSL.Model.get_valid_model!(channel, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    IO.inspect(specs)
    Mix.Task.rerun("phx.gen." <> channel.command, specs)
  end
end
