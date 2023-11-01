defmodule GenDSLTest do
  use ExUnit.Case
  doctest GenDSL

  @app "test/templates/app.json"
  @app_plugin "test/templates/app_plugin.json"
  @auth "test/templates/auth.json"
  @cert "test/templates/cert.json"
  @channel "test/templates/channel.json"
  @context "test/templates/context.json"
  @embedded "test/templates/embedded.json"
  @html "test/templates/html.json"
  @json "test/templates/json.json"
  @live "test/templates/live.json"
  @notifier "test/templates/notifier.json"
  @presence "test/templates/presence.json"
  @release "test/templates/release.json"
  @schema "test/templates/schema.json"
  @secret "test/templates/secret.json"
  @socket "test/template/socket.json"

  def assert_single_element(filepath) do
    baseline_element = TestHelpers.read_single_element(filepath)
    generated_element = GenDSL.Parser.read_blueprint(filepath) |> List.last()

    baseline_element
    |> Map.keys()
    |> Enum.each(fn key ->
      case key do
        "type" ->
          assert true

        _ ->
          assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
      end
    end)
  end

  def assert_schema_fields_equal(baseline_element, generated_element) do
    baseline_element["fields"]
    |> Stream.with_index()
    |> Enum.each(fn {field, index} ->
      field
      |> Map.keys()
      |> Enum.each(fn field_key ->
        case field_key do
          "field_name" ->
            generated_element_value =
              generated_element.fields
              |> Enum.at(index)
              |> Map.fetch!(field_key |> String.to_atom())

            baseline_element_value = field[field_key]
            assert generated_element_value == baseline_element_value

          "datatype" ->
            generated_element_value =
              generated_element.fields
              |> Enum.at(index)
              |> Map.fetch!(field_key |> String.to_atom())

            generated_element_value = generated_element_value |> Atom.to_string()
            baseline_element_value = field[field_key]
            assert generated_element_value == baseline_element_value
        end
      end)
    end)
  end

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

  test "Parsing App Plugin Element" do
    baseline_element = TestHelpers.read_single_element(@app_plugin)
    generated_element = GenDSL.Parser.read_blueprint(@app_plugin) |> List.last()

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

  test "Parsing Cert Element" do
    assert_single_element(@cert)
  end

  test "Parsing Channel Element" do
    assert_single_element(@channel)
  end

  test "Parsing Notifier Element" do
    assert_single_element(@notifier)
  end

  test "Parsing Presence Element" do
    assert_single_element(@presence)
  end

  test "Parsing Schema and SchemaField Elements" do
    baseline_element = TestHelpers.read_single_element(@schema)
    generated_element = GenDSL.Parser.read_blueprint(@schema) |> List.last()

    baseline_element
    |> Map.keys()
    |> Enum.each(fn key ->
      case key do
        "type" ->
          assert true

        "fields" ->
          assert_schema_fields_equal(baseline_element, generated_element)

        _ ->
          assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
      end
    end)
  end
end
