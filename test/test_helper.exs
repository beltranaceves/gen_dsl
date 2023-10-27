defmodule TestHelpers do

  def read_single_element(filepath) do
    case File.read(filepath) do
        {:ok, body} -> Poison.decode!(body) |> List.last()
        {:error, reason} -> IO.puts(reason)
      end
  end

end

ExUnit.start()
