defmodule GenDSL.Model.Notifier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Notifier" do
    field(:context, :string)
    field(:name, :string)
    field(:message_names, {:array, :string})
    field(:merge_with_existing_context, :boolean, default: true)
    field(:context_app, :string)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "notifier")
  end

  @required_fields ~w[context name message_names path]a
  @optional_fields ~w[context_app merge_with_existing_context]a

  @flags ~w[merge_with_existing_context]a
  @named_arguments ~w[context_app]a
  @positional_arguments ~w[context name message_names]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    notifier =
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

    %{"arguments" => notifier, "callback" => task}
  end

  def execute(notifier) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_notifier] =
      GenDSL.Model.get_valid_model!(notifier, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    pipe_command = " >> " <> notifier.log_filepath # TODO: select the correct pipe command based on the OS with a case statement

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> notifier.command, specs)
    # File.cd!(notifier.path)
    Mix.shell().cmd("mix phx.gen." <> notifier.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command)
  end
end
