defmodule GenDSLTest do
  use ExUnit.Case
  doctest GenDSL

  @app "test/templates/app.json"

  test "greets the world" do
    assert GenDSL.hello() == :world
  end

  test "HTML element" do
    baseline_element = TestHelpers.read_single_element(@app)
    generated_element = GenDSL.Parser.read_blueprint(@app) |> List.last()

    baseline_element
    |> Map.keys()
    |> Enum.each(fn key ->
      case key do
        "type" ->
          assert true

        "database" ->
          assert generated_element |> Map.fetch!(key |> String.to_atom()) |> Atom.to_string() ==
                   baseline_element[key]

        _ ->
          assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
      end
    end)
  end
end
