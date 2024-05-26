defmodule GenDSL.Model.ReturnDir do
  def to_task(params) do
    task = &execute/1

    %{"arguments" => params, "callback" => task}
  end

  def execute(args) do
    case Map.fetch(args, "dir") do
      {:ok, dir} ->
        File.cd!(dir)

      :error ->
        File.cd!("..")
    end
  end
end
