defmodule GenDSL.Model.Nerves do
  use Ecto.Schema
  import Ecto.Changeset

  schema "App" do
    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "new")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[path]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    app =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true ->
            changeset |> Ecto.Changeset.apply_changes()

          false ->
            raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => app, "callback" => task}
  end

  # TODO: split app creation and fetching deps into separate commands/entities, such that I can capture the output separatelly and log instructions to the CLI
  def execute(app) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_app] =
      GenDSL.Model.get_valid_model!(app, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    output_path = Path.join(app.path, app.log_filepath)
    _pipe_command = " | tee -a " <> output_path

    IO.puts("Generating project and fetching deps")
    # Mix.Task.rerun("phx." <> app.command, specs)
    Mix.shell().cmd("rm -rf " <> app.path)
    # Mix.Tasks.Phx.New.run(specs)
    output =
      ExUnit.CaptureIO.capture_io(fn ->
        Mix.Tasks.Nerves.New.run(specs)
      end)

    IO.puts(output)
    # Write the output to the specified file
    File.write!(output_path, output)

    # case File.cd(app.path) do
    #   :ok -> IO.puts("Changed directory to " <> app.path)
    #   {:error, _} -> IO.puts("Failed to change directory to " <> app.path)
    # end

    # GenDSL.generate_from_filepath("test/templates/app.json")
    # Mix.shell().cmd(
    #   "mkdir " <>
    #     app.path <>
    #     "| yes | mix phx." <> app.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    # )
  end
end
