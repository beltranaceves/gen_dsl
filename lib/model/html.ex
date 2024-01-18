defmodule GenDSL.Model.Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean, default: false)
    field(:no_schema, :boolean, default: false)
    field(:context_app, :string)

    # {name, table, fields, flags} # TODO: Check values with changeset for valid datatypes in fields
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:command, :string, default: "html")

    # TODO: check XOR schema/no_schema with constraints
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web context_app no_context no_schema]a
  # TODO: revise list when a method to XOR fields is introduced
  @remainder_fields ~w[]a

  @flags ~w[no_context no_schema]a
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
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
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

    specs = (specs ++ valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags) |> List.flatten()
    IO.inspect(specs)
    Mix.Task.run("phx.gen." <> html.command, specs)
  end
end
