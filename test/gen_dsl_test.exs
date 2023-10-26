defmodule GenDSLTest do
  use ExUnit.Case
  doctest GenDSL

  @app "./app.json"

  test "greets the world" do
    assert GenDSL.hello() == :world
  end

  test "HTML elements" do

  end

end
