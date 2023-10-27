defmodule GenDSLTest do
  use ExUnit.Case
  doctest GenDSL

  @app "test/templates/app.json"
  @auth "test/template/auth.json"
  @cert "test/template/cert.json"
  @channel "test/template/channel.json"
  @context "test/template/context.json"
  @embedded "test/template/embedded.json"
  @html "test/template/html.json"
  @json "test/template/json.json"
  @live "test/template/live.json"
  @notifier "test/template/notifier.json"
  @presence "test/template/presence.json"
  @release "test/template/release.json"
  @schema "test/template/schema.json"
  @secret "test/template/secret.json"
  @socket "test/template/socket.json"

  test "Parsing App Element" do
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

  test "Parsing Auth Element" do
    baseline_element = TestHelpers.read_single_element(@auth)
    generated_element = GenDSL.Parser.read_blueprint(@auth) |> List.last()

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
