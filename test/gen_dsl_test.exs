defmodule GenDSLTest do
  use ExUnit.Case
  doctest GenDSL

  test "greets the world" do
    assert GenDSL.hello() == :world
  end
end
