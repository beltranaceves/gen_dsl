defmodule GenDSL.Model.Context do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Context" do
    field(:context, :string)
    # TODO: Validate context is a valid module name (eg. capital letter at the beginning)
    field(:no_schema, :boolean, default: false)
    # TODO: validate XOR merge_with_existing_context or no_merge_with_existing_context
    field(:merge_with_existing_context, :boolean, default: true)
    field(:no_merge_with_existing_context, :boolean, default: false)

    # TODO: Check values with changeset for valid datatypes
    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:command, :string, default: "context")
  end

  @required_fields ~w[context path]a
  @optional_fields ~w[no_schema merge_with_existing_context no_merge_with_existing_context]a
  @remainder_fields ~w[]a

  @flags ~w[no_schema merge_with_existing_context no_merge_with_existing_context]a
  @named_arguments ~w[]a
  @positional_arguments ~w[context]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    # TODO: make required key dependent on no_schema flag for all embedded schemas
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.embedded_changeset/2)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    context =
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

    %{"arguments" => context, "callback" => task}
  end

  def execute(context) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_context] =
      GenDSL.Model.get_valid_model!(context, @positional_arguments, @flags, @named_arguments)

    #
    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(context.schema)

    specs =
      (specs ++
         valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags)
      |> List.flatten()

    pipe_command = " >> " <> context.log_filepath # TODO: select the correct pipe command based on the OS with a case statement

    IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> context.command, specs)
    File.cd!(context.path)
    Mix.shell().cmd("mix phx.gen." <> context.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command)
  end
end
