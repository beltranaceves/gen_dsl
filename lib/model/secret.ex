defmodule GenDSL.Model.Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field(:length, :integer, default: 32)

    field(:path, :string)
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
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
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

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> secret.command, specs)
    File.cd!(secret.path)
    Mix.shell().cmd("mix phx.gen." <> secret.command <> " " <> (specs |> Enum.join(" ")))
  end
end
