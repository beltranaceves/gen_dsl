# TODO: separate model into different files within app context
# TODO: study specific case of Schema, as reference instead of map as it uses all of the same elements/fields of the command. Search how to cast nested Ecto Schemas
defmodule App do
  use Ecto.Schema
  import Ecto.Changeset

  schema "App" do
    field(:path, :string)
    field(:umbrella, :boolean)
    field(:app, :string)
    field(:module, :string)
    # TODO: Check values with changeset validation: postgres, mysql, mssql, sqlite3
    field(:database, :string)
    field(:no_assets, :boolean)
    field(:no_esbuild, :boolean)
    field(:no_tailwind, :boolean)
    field(:no_dashboard, :boolean)
    field(:no_ecto, :boolean)
    field(:no_gettext, :boolean)
    field(:no_html, :boolean)
    field(:no_live, :boolean)
    field(:no_mailer, :boolean)
    field(:binary_id, :boolean)
    field(:verbose, :boolean)
    # TODO: check if this still runs the rest of the command
    field(:version, :boolean)
    field(:install, :boolean)
    field(:no_install, :boolean)
    field(:command, :string, default: "new")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[umbrella app module database no_assets no_esbuild no_tailwind no_dashboard no_ecto no_gettext no_html no_live no_mailer binary_id verbose install no_install]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)

    # {name, table, fields, flags} # TODO: Check values with changeset for valid datatypes in fields
    embeds_one(:schema, Schema)

    field(:command, :string, default: "html")

    # TODO: check XOR schema/no_schema with constraints
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  # TODO: revise list when a method to XOR fields is introduced
  @remainder_fields ~w[context web no_context no_schema context_app]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end

defmodule Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Schema" do
    field(:module, :string)
    field(:name, :string)
    field(:no_migration, :boolean)
    field(:table, :string)
    field(:binary_id, :boolean)
    field(:command, :string, default: "schema")

    embeds_many(:fields, SchemaField)
  end

  @required_fields ~w[module name]a
  @optional_fields ~w[no_migration table binary_id]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> cast_embed(:fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule SchemaField do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":SchemaField" do
    field(:field_name, :string)
    field(:datatype, Ecto.Enum, values: [:id, :binary_id, :integer, :float, :boolean, :string, :binary, :map, :decimal, :date, :time, :time_usec, :naive_datetime, :naive_datetime_usec, :utc_datetime, :utc_datetime_usec]) # TODO: Check values with changeset for valid datatypes # TODO: how to handle enums definition
  end

  @required_fields ~w[field_name datatype]a
  @optional_fields ~w[]a

  def changeset(_, params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Notifier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Notifier" do
    field(:context, :string)
    field(:name, :string)
    field(:message_names, {:array, :string})
    field(:context_app, :string)
    field(:command, :string, default: "notifier")
  end

  @required_fields ~w[context name message_names]a
  @optional_fields ~w[context_app]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field(:length, :integer, default: 32)
    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[length]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Json do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Json" do
    field(:context, :string)
    field(:api_prefix, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end

defmodule Embededd do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Embededd" do
    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)
    field(:command, :string, default: "embededd")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end

defmodule Release do
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
end

defmodule Socket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Socket" do
    field(:module, :string)
    field(:command, :string, default: "socket")
  end

  @required_fields ~w[module]a
  @optional_fields ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Live do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Live" do
    field(:context, :string)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "live")
  end

  @required_fields ~w[]a
  @optional_fields ~w[context web no_context no_schema context_app]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end

defmodule Presence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Presence" do
    field(:module, :string, default: "Presence")

    field(:command, :string, default: "presence")
  end

  @required_fields ~w[]a
  @optional_fields ~w[module]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Context do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Context" do
    field(:context, :string)
    field(:no_schema, :boolean)
    field(:merge_with_existing_context, :boolean)
    field(:no_merge_with_existing_context, :boolean)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "context")
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web no_context no_schema merge_with_existing_context no_merge_with_existing_context]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end

defmodule Cert do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Cert" do
    field(:app, :string)
    field(:domain, :string)
    field(:url, :string)
    field(:output, :string)
    field(:name, :string)
    field(:command, :string, default: "cert")
  end

  @required_fields ~w[]a
  @optional_fields ~w[app domain url output name]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Channel" do
    field(:module, :string)
    field(:command, :string, default: "channel")
  end

  @required_fields ~w[module]a
  @optional_fields ~w[]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end
end

defmodule Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Auth" do
    field(:context, :string)
    field(:web, :string)
    # TODO: check valid input
    field(:hashing_lib, :string)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, Schema)

    field(:command, :string, default: "auth")
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web hashing_lib]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &Schema.changeset/1)
    |> validate_required(@required_fields)
  end
end
