# TODO: study specific case of Schema, as reference instead of map as it uses all of the same elements/fields of the command. Search how to cast nested Ecto Schemas
defmodule GenDSL.Model.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Schema" do
    field(:module, :string)
    # TODO: validate module is a valid module name (eg. uppercase letter at the beginning)
    field(:name, :string)
    # TODO: validate name is a valid module name (eg. lowercase)
    field(:table, :string)
    field(:repo, :string)
    field(:migration_dir, :string)
    field(:prefix, :string)
    field(:no_migration, :boolean)
    field(:binary_id, :boolean)
    field(:command, :string, default: "schema")

    embeds_many(:fields, GenDSL.Model.SchemaField)
  end

  @required_fields ~w[module name]a
  @optional_fields ~w[no_migration table binary_id repo migration_dir prefix]a
  # @remainder_fields ~w[]a

  @flags ~w[no_migration binary_id]a
  @named_arguments ~w[table repo migration_dir prefix]a
  @positional_arguments ~w[module name]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> cast_embed(:fields, required: false)
    |> validate_required(@required_fields)
  end

  def embedded_changeset(_parent, params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> cast_embed(:fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    schema =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => schema, "callback" => task}
  end

  def execute(schema) do
    specs = []

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(schema)

    specs = (specs ++ valid_schema_spec) |> List.flatten()
    IO.inspect(specs)
    Mix.Task.rerun("phx.gen." <> schema.command, specs)
  end

  def to_valid_spec(schema) do
    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_schema] =
      GenDSL.Model.get_valid_model!(schema, @positional_arguments, @flags, @named_arguments)

    fields_specs =
      case schema |> Map.fetch(:fields) do
        {:ok, fields} ->
          fields |> Enum.map(fn field -> GenDSL.Model.SchemaField.to_valid_spec(field) end)

        :error ->
          []
      end

    IO.puts("Schema spec")
    IO.inspect(valid_positional_arguments, label: "valid_positional_arguments")
    IO.inspect(valid_flags, label: "valid_flags")
    IO.inspect(valid_named_arguments, label: "valid_named_arguments")

    ([valid_positional_arguments, valid_flags, valid_named_arguments] ++ fields_specs)
    |> List.flatten()
  end
end

defmodule GenDSL.Model.SchemaField do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":SchemaField" do
    field(:field_name, :string)
    # TODO: Check values with changeset for valid datatypes # TODO: how to handle enums definition
    field(:datatype, Ecto.Enum,
      values: [
        :id,
        :binary_id,
        :integer,
        :float,
        :boolean,
        :string,
        :binary,
        :map,
        :decimal,
        :date,
        :time,
        :time_usec,
        :naive_datetime,
        :naive_datetime_usec,
        :utc_datetime,
        :utc_datetime_usec
      ]
    )
  end

  @required_fields ~w[field_name datatype]a
  @optional_fields ~w[]a

  # @flags ~w[]a
  # @named_parameters ~w[field_name datatype]a

  def changeset(_, params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_valid_spec(schema_field) do
    schema_field.field_name <> ":" <> (schema_field.datatype |> Atom.to_string())
  end
end
