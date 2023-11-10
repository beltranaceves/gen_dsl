defmodule GenDSL.Model.Cert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Cert" do
    field(:app, :string)
    field(:domain, :string)
    field(:url, :string)
    field(:output, :string)
    field(:name, :string)
    field(:command, :string, default: "cert")
  end

  @required_fields ~w[]a
  @optional_fields ~w[app domain url output name]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

def to_task(params) do
    cert =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => cert, "callback" => task}
  end

  def execute(cert) do
    specs = []

    specs
    |> Mix.Tasks.Phx.Gen.Cert.run()
  end
end
