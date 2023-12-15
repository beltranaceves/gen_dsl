defmodule GenDSL.Model.Notifier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Notifier" do
    field(:context, :string)
    field(:name, :string)
    field(:message_names, {:array, :string})
    field(:context_app, :string)

    field(:command, :string, default: "notifier")
  end

  @required_fields ~w[context name message_names]a
  @optional_fields ~w[context_app]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    notifier =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => notifier, "callback" => task}
  end

  def execute(notifier) do
    specs = []

    Mix.Task.run(notifier.command, specs)
  end
end
