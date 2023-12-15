# TODO: study specific case of Schema, as reference instead of map as it uses all of the same elements/fields of the command. Search how to cast nested Ecto Schemas
defmodule GenDSL.Model.Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Schema" do
    field(:module, :string)
    field(:name, :string)
    field(:no_migration, :boolean)
    field(:table, :string)
    field(:binary_id, :boolean)
    field(:command, :string, default: "schema")

    embeds_many(:fields, GenDSL.Model.SchemaField)
  end

  @required_fields ~w[module name]a
  @optional_fields ~w[no_migration table binary_id]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> cast_embed(:fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    schema =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => schema, "callback" => task}
  end

  def execute(schema) do
    specs = []

    Mix.Task.run(schema.command, specs)
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

  def changeset(_, params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end
