# TODO: separate model into different files within app context
# TODO: study specific case of Schema, as reference instead of map as it uses all of the same elements/fields of the command. Search how to cast nested Ecto Schemas
defmodule Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Application" do
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

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field(:contex, :string)

    # {name, table, fields, flags} # TODO: Check values with changeset for valid datatypes in fields
    field(:schema, :map)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)
    field(:command, :string, default: "html")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Schema" do
    field(:module, :string)
    field(:name, :string)
    # TODO: Check values with changeset for valid datatypes # TODO: how to handle enums definition
    field(:fields, :map)
    field(:no_migration, :boolean)
    field(:table, :string)
    field(:binary_id, :boolean)
    field(:command, :string, default: "schema")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
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

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
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
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Json do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Json" do
    field(:context, :string)
    # TODO: Check values with changeset for valid datatypes
    field(:schema, :map)
    field(:api_prefix, :string)
    field(:command, :string, default: "secret")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Embededd do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Embededd" do
    field(:schema, :map)
    field(:command, :string, default: "embededd")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
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
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Socket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Socket" do
    field(:module, :string)
    field(:command, :string, default: "socket")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Live do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Live" do
    field(:context)
    :string
    field(:schema, :map)
    field(:web, :string)
    field(:no_context, :boolean)
    field(:no_schema, :boolean)
    field(:context_app, :string)
    field(:command, :string, default: "live")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Presence do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Presence" do
    field(:module, :string)
    field(:command, :string, default: "presence")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Context do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Context" do
    field(:context, :string)
    field(:schema, :map)
    field(:no_schema, :boolean)
    field(:merge_with_existing_context, :boolean)
    field(:no_merge_with_existing_context, :boolean)
    field(:command, :string, default: "context")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
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
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Channel" do
    field(:module, :string)
    field(:command, :string, default: "channel")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end

defmodule Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Auth" do
    field(:context, :string)
    field(:schema, :map)
    field(:web, :string)
    # TODO: check valid input
    field(:hashing_lib, :string)
    field(:command, :string, default: "auth")
  end

  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false)
  end
end
