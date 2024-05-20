defmodule GenDSL.Model.Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Release" do
    field(:docker, :boolean)
    field(:no_ecto, :boolean)
    field(:ecto, :boolean)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "release")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[docker no_ecto ecto]a

  @flags ~w[docker no_ecto ecto]a
  @named_arguments ~w[]a
  @positional_arguments ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    release =
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

    %{"arguments" => release, "callback" => task}
  end

  def execute(release) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_release] =
      GenDSL.Model.get_valid_model!(release, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> release.log_filepath

    IO.inspect(specs)
    case File.cd(release.path) do
      :ok -> IO.puts("Changed directory to " <> release.path)
      {:error, _} -> IO.puts("Failed to change directory to " <> release.path)
    end
    # Mix.Task.rerun("phx.gen." <> release.command, specs)
    # File.cd!(release.path)
    Mix.shell().cmd(
      "mix phx.gen." <> release.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
