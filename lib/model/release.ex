defmodule GenDSL.Model.Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Release" do
    field(:docker, :boolean)
    field(:no_ecto, :boolean)
    field(:ecto, :boolean)
    field(:command, :string, default: "release")
  end

  @required_fields ~w[]a
  @optional_fields ~w[docker no_ecto ecto]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    release =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => release, "callback" => task}
  end

  def execute(release) do
    specs = []

    Mix.Task.run(release.command, specs)
  end
end
