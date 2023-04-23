defmodule Html do
  use Ecto.Schema
  import Ecto.Changeset

  schema ":Html" do
    has_one :contex, Context
    has_one :schema, Schema
    field :web, :string
  end
  @required_fields ~w[]a
  @optional_fields ~w[avg_pass, avg_fail, total_students ]a


  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @optional_fields, required: false )
  end
end


# Generable elements
defmodule :Html do
  defstruct [
    :context,
    :schema,
    :web,
    "no-context": false,
    "no-schema": false,
    command: "html"
  ]

  use ExConstructor
end

defmodule :Schema do
  defstruct [
    :fields,
    "no-migration": false,
    command: "schema"
  ]

  use ExConstructor
end

defmodule :Notifier do
  defstruct [
    :context,
    :notifier_name,
    message_names: [],
    command: "notifier"
  ]

  use ExConstructor
end

defmodule :Secret do
  defstruct [
    :length,
    command: "secret"
  ]

  use ExConstructor
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
