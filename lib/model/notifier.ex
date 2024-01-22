defmodule GenDSL.Model.Notifier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Notifier" do
    field(:context, :string)
    field(:name, :string)
    field(:message_names, {:array, :string})
    field(:context_app, :string)

    field(:path, :string)
    field(:command, :string, default: "notifier")
  end

  @required_fields ~w[context name message_names path]a
  @optional_fields ~w[context_app]a

  @flags ~w[]a
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
          false -> raise "Invalid changeset"
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

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> notifier.command, specs)
    File.cd!(notifier.path)
    Mix.shell().cmd("mix phx.gen." <> notifier.command <> " " <> (specs |> Enum.join(" ")))
  end
end
