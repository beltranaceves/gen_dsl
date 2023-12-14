defmodule GenDSLTest do
  use ExUnit.Case
  use ExUnitProperties
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
    baseline_element = TestHelpers.read_blueprint(filepath)["generable_elements"] |> List.last()
    # TODO: rewrite the order of this methods correctly
    generated_element =
      filepath
      |> GenDSL.Parser.read_blueprint()
      |> case do
        {:ok, blueprint} ->
          (blueprint |> GenDSL.Parser.process_blueprint())["generable_elements"]
          |> List.last()

        {:error, reason} ->
          IO.puts(reason)
      end

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
    baseline_element = TestHelpers.read_blueprint(@app)["generable_elements"] |> List.last()

    generated_element =
      GenDSL.Parser.read_blueprint(@app)["generable_elements"]
      |> GenDSL.Parser.process_blueprint()
      |> List.last()

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
    baseline_element =
      TestHelpers.read_blueprint(@app_plugin)["generable_elements"] |> List.last()

    generated_element =
      GenDSL.Parser.read_blueprint(@app_plugin)["generable_elements"] |> List.last()

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
    baseline_element = TestHelpers.read_blueprint(@schema)["generable_elements"] |> List.last()
    generated_element = GenDSL.Parser.read_blueprint(@schema)["generable_elements"] |> List.last()

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

  describe "process_blueprint/1" do
    property "StreamData generated map is valid gen_dsl" do
      check(
        all(
          blueprint <-
            StreamData.optional_map(
              %{
                type: StreamData.constant("App"),
                path:
                  StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 35),
                umbrella: StreamData.boolean(),
                app:
                  StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 35),
                module:
                  StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 35),
                database: StreamData.one_of([:postgres, :mysql, :mssql, :sqlite3]),
                no_assets: StreamData.boolean(),
                no_esbuild: StreamData.boolean(),
                no_tailwind: StreamData.boolean(),
                no_dashboard: StreamData.boolean(),
                no_ecto: StreamData.boolean(),
                no_gettext: StreamData.boolean(),
                no_html: StreamData.boolean(),
                no_live: StreamData.boolean(),
                no_mailer: StreamData.boolean(),
                binary_id: StreamData.boolean(),
                verbose: StreamData.boolean(),
                install: StreamData.boolean(),
                no_install: StreamData.boolean()
              },
              [
                :umbrella,
                :module,
                :database,
                :no_assets,
                :no_esbuild,
                :no_tailwind,
                :no_dashboard,
                :no_ecto,
                :no_gettext,
                :no_html,
                :no_live,
                :no_mailer,
                :binary_id,
                :verbose,
                :install,
                :no_install
              ]
            )
        )
      ) do
        IO.inspect(blueprint)
        assert true
        # Generate AST spec form blueprint
        # Generate project with Mix Tasks
        # Generate AST from generated project
        # Compare ASTs with diffing algorithm
        # Delete generated project
      end
    end
  end
end
