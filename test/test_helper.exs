defmodule TestHelpers do
  def read_blueprint(filepath) do
    case File.read(filepath) do
      {:ok, body} -> Poison.decode!(body)
      {:error, reason} -> IO.puts(reason)
    end
  end
end

ExUnit.start()
