defmodule GenDSL.Model.Cert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Cert" do
    field(:app, :string)
    field(:domain, :string)
    field(:url, :string)
    field(:output, :string)
    field(:name, :string)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "cert")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[app domain url output name]a
  # TODO: validate that either no params are passed or app domain and url are passed

  @flags ~w[]a
  @named_arguments ~w[output name]a
  @positional_arguments ~w[app domain url]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    cert =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false ->
            IO.puts("Invalid changeset")
            IO.inspect(params, label: "params")
            IO.inspect(changeset, label: "changeset")
            IO.inspect(changeset.errors)
            raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => cert, "callback" => task}
  end

  def execute(cert) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_cert] =
      GenDSL.Model.get_valid_model!(cert, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    pipe_command = " >> " <> cert.log_filepath # TODO: select the correct pipe command based on the OS with a case statement

    IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> cert.command, specs)
    File.cd!(cert.path)
    Mix.shell().cmd("mix phx.gen." <> cert.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command)
  end
end
