defmodule GenDSL.Model.App do
  use Ecto.Schema
  import Ecto.Changeset

  schema "App" do
    field(:path, :string)
    field(:umbrella, :boolean)
    field(:app, :string)
    field(:module, :string)
    field(:database, Ecto.Enum, values: [:postgres, :mysql, :mssql, :sqlite3])
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
    # TODO: validate install and no_install are not both true
    field(:install, :boolean)
    field(:no_install, :boolean, default: true)
    # Alternative way to build the install field flag
    # field(:install, Ecto.Enum, values: [:"--install", :"--no-install"], default: :"--install")
    field(:command, :string, default: "new")
  end

  @required_fields ~w[path]a
  @optional_fields ~w[umbrella app module database no_assets no_esbuild no_tailwind no_dashboard no_ecto no_gettext no_html no_live no_mailer binary_id verbose install no_install]a

  @flags ~w[umbrella no_assets no_esbuild no_tailwind no_dashboard no_ecto no_gettext no_html no_live no_mailer binary_id verbose install no_install]a
  @named_arguments ~w[app module database]a

  @spec changeset(%{}) :: Ecto.Changeset.t()
  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    app =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true ->
            changeset |> Ecto.Changeset.apply_changes()

          false ->
            raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => app, "callback" => task}
  end

  def execute(app) do
    specs = [app.path]

    [valid_flags, valid_named_arguments, _valid_app] =
      GenDSL.Model.validate_model(app, @flags, @named_arguments)

    specs = (specs ++ valid_flags ++ valid_named_arguments) |> List.flatten()
    IO.inspect(specs)
    # Mix.Task.reenable("phx" <> app.command)
    Mix.Task.rerun("phx." <> app.command, specs)
    # Mix.Task.reenable("phx" <> app.command)
  end
end
