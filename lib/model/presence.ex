defmodule GenDSL.Model.Presence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Presence" do
    field(:module, :string, default: "Presence")

    field(:command, :string, default: "presence")
  end

  @required_fields ~w[]a
  @optional_fields ~w[module]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[module]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    presence =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => presence, "callback" => task}
  end

  def execute(presence) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_presence] =
      GenDSL.Model.get_valid_model!(presence, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    IO.inspect(specs)
    Mix.Task.rerun("phx.gen." <> presence.command, specs)
  end
end
