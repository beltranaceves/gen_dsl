defmodule GenDSL.Model.Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field(:length, :integer, default: 32)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "secret")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[length]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[length]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    secret =
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

    %{"arguments" => secret, "callback" => task}
  end

  def execute(secret) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_secret] =
      GenDSL.Model.get_valid_model!(secret, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> secret.log_filepath

    IO.inspect(specs)
    case File.cd(secret.path) do
      :ok -> IO.puts("Changed directory to " <> secret.path)
      {:error, _} -> IO.puts("Failed to change directory to " <> secret.path)
    end
    # Mix.Task.rerun("phx.gen." <> secret.command, specs)
    # File.cd!(secret.path)
    Mix.shell().cmd(
      "mix phx.gen." <> secret.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
