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

  def generate_from_filepath(filename) do
    filename
    |> read_blueprint()
    |> case do
      {:ok, blueprint} ->
        blueprint
        |> generate_from_blueprint()

      {:error, reason} ->
        IO.puts("Error generating from filepath")
        IO.puts(reason)
        {:error, reason}
    end
  end

  def generate_from_blueprint(blueprint) do
    # TODO: implement an add_postrequisites function. At least ad a task to log: "Please check INSTRUCTIONS.md to complete installation."
    blueprint
    |> sanitize_blueprint()
    |> add_prerequisites()
    |> add_postrequisites()
    |> process_blueprint()
    |> execute_blueprint()
  end
end
