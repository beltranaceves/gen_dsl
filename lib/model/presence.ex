defmodule GenDSL.Model.Presence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Presence" do
    field(:module, :string, default: "Presence")

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "presence")
  end

  @required_fields ~w[path]a
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
          true ->
            changeset |> Ecto.Changeset.apply_changes()

          false ->
            IO.puts("Invalid changeset")
            IO.inspect(params, label: "params")
            IO.inspect(changeset, label: "changeset")
            IO.inspect(changeset.errors)
            raise "Invalid changeset"
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

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> presence.log_filepath

    IO.inspect(specs)

    case File.cd(presence.path) do
      :ok -> IO.puts("Changed directory to " <> presence.path)
      {:error, _} -> IO.puts("Failed to change directory to " <> presence.path)
    end

    Mix.shell().cmd(
      "mix phx.gen." <> presence.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
