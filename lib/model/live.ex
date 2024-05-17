defmodule GenDSL.Model.Live do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Live" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:merge_with_existing_context, :boolean, default: true)
    field(:context_app, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "live")
  end

  @required_fields ~w[context path]a
  @optional_fields ~w[web no_context no_schema context_app merge_with_existing_context]a
  @remainder_fields ~w[]a

  @flags ~w[no_context no_schema merge_with_existing_context]a
  @named_arguments ~w[web context_app]a
  @positional_arguments ~w[context]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.embedded_changeset/2)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    live =
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

    %{"arguments" => live, "callback" => task}
  end

  def execute(live) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_live] =
      GenDSL.Model.get_valid_model!(live, @positional_arguments, @flags, @named_arguments)

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(live.schema)

    specs =
      (specs ++
         valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags)
      |> List.flatten()

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> live.command, specs)
    File.cd!(live.path)
    Mix.shell().cmd("mix phx.gen." <> live.command <> " " <> (specs |> Enum.join(" ")))
  end
end
