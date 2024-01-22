defmodule GenDSL.Model.Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Auth" do
    field(:context, :string)
    # TODO: Validate context is a valid module name (eg. capital letter at the beginning)
    field(:web, :string)
    field(:hashing_lib, Ecto.Enum, values: [bcrypt: "bcrypt", pbkdf2: "pbkdf2", argon2: "argon2"])
    field(:no_live, :boolean, default: false)
    field(:live, :boolean, default: true)
    # TODO: Validate XOR live and no_live flags
    field(:binary_id, :boolean, default: false)
    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:path, :string)
    field(:command, :string, default: "auth")
  end

  @required_fields ~w[context path]a
  @optional_fields ~w[web hashing_lib no_live live binary_id]a
  @remainder_fields ~w[]a

  @flags ~w[no_live live binary_id]a
  @named_arguments ~w[web hashing_lib]a
  @positional_arguments ~w[context]a

  # TODO: figure out how to get the schema values

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    # TODO: check if I really need an embedded schema I can just do with schema module and table fields
    |> cast_embed(:schema, required: true, with: &GenDSL.Model.Schema.embedded_changeset/2)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    auth =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true ->
            changeset |> Ecto.Changeset.apply_changes()

          false ->
            IO.inspect(changeset.errors)
            raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => auth, "callback" => task}
  end

  def execute(auth) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_auth] =
      GenDSL.Model.get_valid_model!(auth, @positional_arguments, @flags, @named_arguments)

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(auth.schema)

    specs =
      (specs ++
         valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags)
      |> List.flatten()

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> auth.command, specs)
    File.cd!(auth.path)
    Mix.shell().cmd("mix phx.gen." <> auth.command <> " " <> (specs |> Enum.join(" ")))
  end
end
