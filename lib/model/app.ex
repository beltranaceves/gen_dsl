defmodule App do
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

  # def to_command((%App{} = app) do

  # end
end
