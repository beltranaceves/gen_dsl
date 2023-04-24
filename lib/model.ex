# TODO: separate model into different files within app context
# TODO: study specific case of Schema, as reference instead of map as it uses all of the same elements/fields of the command. Search how to cast nested Ecto Schemas
defmodule Application do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Application" do
    field :path, :string
    field :umbrella, :boolean
    field :app, :string
    field :module, :string
    field :database, :string # TODO: Check values with changeset validation: postgres, mysql, mssql, sqlite3
    field :no_assets, :boolean
    field :no_esbuild, :boolean
    field :no_tailwind, :boolean
    field :no_dashboard, :boolean
    field :no_ecto, :boolean
    field :no_gettext, :boolean
    field :no_html, :boolean
    field :no_live, :boolean
    field :no_mailer, :boolean
    field :binary_id, :boolean
    field :verbose, :boolean
    field :version, :boolean # TODO: check if this still runs the rest of the command
    field :install, :boolean
    field :no_install, :boolean
    field :command, default: "new"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Html" do
    field :module, :string
    field :contex, :string
    field :schema, :map  # {name, table, fields} # TODO: Check values with changeset for valid datatypes in fields
    field :web, :string
    field :no_context, :boolean
    field :no_context, :boolean
    field :context_app, :string
    field :command, default: "html"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule Schema do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Schema" do
    field :module, :string
    field :name, :string
    field :fields, :map # TODO: Check values with changeset for valid datatypes # TODO: how to handle enums definition
    field :no_migration, :boolean
    field :table, :string
    field :binary_id, :boolean
    field :command, default: "schema"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule Notifier do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Notifier" do
    field :module, :string
    field :name, :string
    field :message_names, {:array, :string}
    field :context_app, :string
    field :command, default: "notifier"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule Secret do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Secret" do
    field :length, :integer, default: 32
    field :command, default: "secret"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule Json do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Json" do
    field :context, :string
    field :module, :string
    field :schema, :map # TODO: Check values with changeset for valid datatypes
    field :api_prefix, :string
    field :command, default: "secret"
  end
  @required_fields ~w[]a
  @optional_fields ~w[]a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end

defmodule :Json do
  defstruct [
    :context,
    :schema,
    :web,
    "no-context": false,
    "no-schema": false,
    command: "json"
  ]

  use ExConstructor
end

defmodule :Embedded do
  defstruct [
    :schema,
    command: "embedded"
  ]

  use ExConstructor
end

defmodule :Release do
  defstruct docker: [],
            "no-ecto": [],
            ecto: [],
            command: "release"

  use ExConstructor
end

defmodule :Socket do
  defstruct [
    :module_name,
    command: "socket"
  ]

  use ExConstructor
end

defmodule :Live do
  defstruct [
    :context,
    :schema,
    :web,
    "no-context": false,
    "no-schema": false,
    command: "live"
  ]

  use ExConstructor
end

defmodule :Presence do
  defstruct [
    :module_name,
    command: "presence"
  ]

  use ExConstructor
end

defmodule :Context do
  defstruct [
    :name,
    :schema,
    "no-schema": false,
    "--merge-with-existing-context": false,
    "--no-merge-with-existing-context": false,
    command: "context"
  ]

  use ExConstructor
end

defmodule :Cert do
  # TODO: i don't understand this one, ask someone
  defstruct command: "cert"
  use ExConstructor
end

defmodule :Channel do
  defstruct [
    :module_name,
    command: "channel"
  ]

  use ExConstructor
end

defmodule :Auth do
  defstruct [
    :context,
    :schema,
    :web,
    "hashing-lib": "bcrypt",
    command: "auth"
  ]

  use ExConstructor
end
