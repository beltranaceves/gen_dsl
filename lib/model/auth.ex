defmodule GenDSL.Model.Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Auth" do
    field(:context, :string)
    field(:web, :string)
    # TODO: check valid input
    # field(:hashing_lib, :string)
    field(:hashing_lib, Ecto.Enum, values: [bcrypt: "bcrypt", pbkdf2: "pbkdf2", argon2: "argon2"])

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:command, :string, default: "auth")
  end

  @required_fields ~w[context]a
  @optional_fields ~w[web hashing_lib]a
  @remainder_fields ~w[schema]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.changeset/1)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    auth =
      params
      |> changeset()
      |> Ecto.Changeset.apply_changes()

    task = &execute/1

    %{"arguments" => auth, "callback" => task}
  end

  def execute(auth) do
    specs = []

    specs
    |> Mix.Tasks.Phx.Gen.Auth.run()
  end
end
