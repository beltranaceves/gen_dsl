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

  # TODO: rework the parameters into a keywork list and handle it like they do in Elixir mix tasks, with switches
  def generate_from_filepath(filename, get_deps \\ true, return_dir \\ nil) do
    filename
    |> read_blueprint()
    |> case do
      {:ok, blueprint} ->
        blueprint
        |> generate_from_blueprint(get_deps, return_dir)

      {:error, reason} ->
        IO.puts("Error generating from filepath")
        IO.puts(reason)
        {:error, reason}
    end
  end

  def generate_from_blueprint(blueprint, get_deps \\ true, return_dir \\ nil) do
    # TODO: implement an add_postrequisites function. At least add a task to log: "Please check INSTRUCTIONS.md to complete installation."
    blueprint
    |> sanitize_blueprint()
    |> add_prerequisites()
    # TODO: try to remove the prefix, is should not be needed but elixir linter cannot find the function without it
    |> GenDSL.Parser.add_postrequisites(return_dir)
    |> process_blueprint()
    |> IO.inspect(label: "Processed blueprint")
    |> GenDSL.Parser.execute_blueprint(get_deps)
  end
end
