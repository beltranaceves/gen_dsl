defmodule GenDSL.Model.Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean, default: false)
    field(:no_schema, :boolean, default: false)
    field(:merge_with_existing_context, :boolean, default: true)
    # TODO: make is so that it only uses this on umbrella applications when supported
    field(:context_app, :string)

    # {name, table, fields, flags} # TODO: Check values with changeset for valid datatypes in fields
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "html")

    # TODO: check XOR schema/no_schema with constraints
  end

  @required_fields ~w[context path]a
  @optional_fields ~w[web context_app no_context no_schema merge_with_existing_context]a
  # TODO: revise list when a method to XOR fields is introduced
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
    html =
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

    %{"arguments" => html, "callback" => task}
  end

  def execute(html) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_html] =
      GenDSL.Model.get_valid_model!(html, @positional_arguments, @flags, @named_arguments)

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(html.schema)

    specs =
      (specs ++
         valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags)
      |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> html.log_filepath

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> html.command, specs)
    # File.cd!(html.path)
    Mix.shell().cmd(
      "mix phx.gen." <> html.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
