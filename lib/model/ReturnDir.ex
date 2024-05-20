defmodule GenDSL.Model.ReturnDir do
  def to_task(_params) do
    task = &execute/1

    %{"arguments" => [], "callback" => task}
  end

  def execute(_args) do
    File.cd!("..")
  end
end
