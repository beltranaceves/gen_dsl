defmodule GenDSL.Model.Socket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "Socket" do
    field(:module, :string)

    field(:path, :string)
    field(:command, :string, default: "socket")
  end

  @required_fields ~w[module path]a
  @optional_fields ~w[]a

  @flags ~w[]a
  @named_arguments ~w[]a
  @positional_arguments ~w[module]a

  def changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields, required: false)
    |> validate_required(@required_fields)
  end

  def to_task(params) do
    socket =
      params
      |> changeset()
      |> then(fn changeset ->
        case changeset.valid? do
          true -> changeset |> Ecto.Changeset.apply_changes()
          false -> raise "Invalid changeset"
        end
      end)

    task = &execute/1

    %{"arguments" => socket, "callback" => task}
  end

  def execute(socket) do
    specs = []

    [valid_positional_arguments, valid_flags, valid_named_arguments, _valid_socket] =
      GenDSL.Model.get_valid_model!(socket, @positional_arguments, @flags, @named_arguments)

    specs =
      (specs ++ valid_positional_arguments ++ valid_flags ++ valid_named_arguments)
      |> List.flatten()

    # IO.inspect(specs)
    # Mix.Task.rerun("phx.gen." <> socket.command, specs)
    File.cd!(socket.path)
    Mix.shell().cmd("mix phx.gen." <> socket.command <> " " <> (specs |> Enum.join(" ")))
  end
end
