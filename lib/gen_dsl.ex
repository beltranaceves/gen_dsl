defmodule GenDSL do
  @moduledoc """
  Documentation for `GenDSL`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> GenDSL.hello()
      :world

  """
  def hello do
    :world
  end

  # A function that reads a JSON file
  # and returns a map.
  def read_json(filename) do
    {:ok, json} = File.read(filename)
    Poison.decode!(json)
  end
end
