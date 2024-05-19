defmodule GenDSL.Model.Hex do
  def to_task(_params) do
    task = &execute/1

    %{"arguments" => [], "callback" => task}
  end

  def execute(_args) do
    specs = ["--force", "--if-missing"]

    command = "local.hex"
    Mix.shell().cmd("mix " <> command <> " " <> (specs |> Enum.join(" ")))
  end
end
