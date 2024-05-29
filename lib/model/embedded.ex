defmodule GenDSL.Model.Embedded do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Embedded" do
    field(:module, :string)
    # TODO: validate module is a valid module name (eg. uppercase letter at the beginning)
    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "embedded")

    embeds_many(:fields, GenDSL.Model.SchemaField)
  end

  @required_fields ~w[module path]a
  @optional_fields ~w[]a
  # @remainder_fields ~w[]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[module]a

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

    %{"arguments" => schema, "callback" => task}
  end

  def execute(schema) do
    specs = []

    valid_schema_spec = GenDSL.Model.Embedded.to_valid_spec(schema)

    specs = (specs ++ valid_schema_spec) |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> schema.log_filepath

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> schema.command, specs)
    # File.cd!(schema.path)
    case File.cd(schema.path) do
      :ok -> IO.puts("Changed directory to " <> schema.path)
      {:error, _} -> IO.puts("Failed to change directory to " <> schema.path)
    end

    IO.puts("mix phx.gen." <> schema.command <> " " <> (specs |> Enum.join(" ")))

    Mix.shell().cmd(
      "mix phx.gen." <> schema.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end

  def to_valid_spec(embedded) do
    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_schema] =
      GenDSL.Model.get_valid_model!(embedded, @positional_arguments, @flags, @named_arguments)

    fields_specs =
      case embedded |> Map.fetch(:fields) do
        {:ok, fields} ->
          fields |> Enum.map(fn field -> GenDSL.Model.SchemaField.to_valid_spec(field) end)

        :error ->
          []
      end

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
