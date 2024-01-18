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
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => cert, "callback" => task}
  end

  def execute(cert) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_cert] =
      GenDSL.Model.get_valid_model!(cert, @positional_arguments, @flags, @named_arguments)

    specs = (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments) |> List.flatten()
    IO.inspect(specs)
    Mix.Task.rerun("phx.gen." <> cert.command, specs)
  end
end
