defmodule GenDSL.Model.Json do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Json" do
    field(:context, :string)
    field(:web, :string)
    field(:context_app, :string)
    field(:merge_with_existing_context, :boolean, default: true)

    # TODO: Check values with changeset for valid datatypes
    embeds_one(:schema, GenDSL.Model.Schema)

    field(:path, :string)
    field(:log_filepath, :string, default: "INSTRUCTIONS.md")
    field(:command, :string, default: "json")
  end

  @required_fields ~w[context path]a
  @optional_fields ~w[web context_app merge_with_existing_context]a
  @remainder_fields ~w[]a

  @flags ~w[merge_with_existing_context]a
  @named_arguments ~w[web context_app]a
  @positional_arguments ~w[context]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields ++ @remainder_fields, required: false)
    |> cast_embed(:schema, required: false, with: &GenDSL.Model.Schema.embedded_changeset/2)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    json =
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

    %{"arguments" => json, "callback" => task}
  end

  def execute(json) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_json] =
      GenDSL.Model.get_valid_model!(json, @positional_arguments, @flags, @named_arguments)

    valid_schema_spec = GenDSL.Model.Schema.to_valid_spec(json.schema)

    specs =
      (specs ++
         valid_positional_arguments ++ valid_schema_spec ++ valid_named_arguments ++ valid_flags)
      |> List.flatten()

    # TODO: select the correct pipe command based on the OS with a case statement
    pipe_command = " >> " <> json.log_filepath

    IO.inspect(specs)

    case File.cd(json.path) do
      :ok -> IO.puts("Changed directory to " <> json.path)
      {:error, _} -> IO.puts("Failed to change directory to " <> json.path)
    end

    # Mix.Task.rerun("phx.gen." <> json.command, specs)
    # File.cd!(json.path)
    Mix.shell().cmd(
      "mix phx.gen." <> json.command <> " " <> (specs |> Enum.join(" ")) <> pipe_command
    )
  end
end
