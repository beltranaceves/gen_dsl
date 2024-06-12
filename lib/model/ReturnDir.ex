defmodule GenDSL.Model.ReturnDir do
  def to_task(params) do
    task = &execute/1

    %{"arguments" => params, "callback" => task}
  end

  def execute(args) do
    IO.puts("Returning to the previous directory: #{inspect(args)}")

    case Map.fetch(args, "dir") do
      {:ok, dir} ->
        case dir do
          nil -> File.cd!("..")
          _ -> File.cd!(dir)
        end

      :error ->
        File.cd!("..")
    end
  end
end
