defmodule Notifier do
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
end
