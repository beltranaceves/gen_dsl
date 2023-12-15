defmodule GenDSL.Model.Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field(:length, :integer, default: 32)
    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[length]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    secret =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => secret, "callback" => task}
  end

  def execute(secret) do
    specs = []

    Mix.Task.run(secret.command, specs)
  end
end
