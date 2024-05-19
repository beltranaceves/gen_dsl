defmodule GenDSL.Model.Embedded do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Embededd" do
    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)
    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "embededd")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[]a
  @remainder_fields ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.embedded_changeset/2)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    embedded =
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

    %{"arguments" => embedded, "callback" => task}
  end

  def execute(embedded) do
    specs = []

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(embedded.schema)

    specs = (specs ++ valid_schema_spec) |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> embedded.log_filepath

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> embedded.command, specs)
    # File.cd!(embedded.path)
    Mix.shell().cmd(
      "mix phx.gen." <> embedded.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
