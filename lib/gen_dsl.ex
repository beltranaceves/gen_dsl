defmodule GenDSL do
  @moduledoc """
  Documentation for `GenDSL`.
  """
  import GenDSL.Parser

  @doc """
  Hello world.

  ## Examples

      iex> GenDSL.hello()
      :world

  """
  def hello do
    :world
  end

  def generate_from_filepath(filename, get_deps \\ true) do
    filename
    |> read_blueprint()
    |> case do
      {:ok, blueprint} ->
        blueprint
        |> generate_from_blueprint(get_deps)

      {:error, reason} ->
        IO.puts("Error generating from filepath")
        IO.puts(reason)
        {:error, reason}
    end
  end

  def generate_from_blueprint(blueprint, get_deps \\ true) do
    # TODO: implement an add_postrequisites function. At least add a task to log: "Please check INSTRUCTIONS.md to complete installation."
    blueprint
    |> sanitize_blueprint()
    |> add_prerequisites()
    |> add_postrequisites()
    |> process_blueprint()
    |> execute_blueprint(get_deps)
  end
end
