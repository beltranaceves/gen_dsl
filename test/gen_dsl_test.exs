defmodule GenDSLTest do
  alias ElixirLS.LanguageServer.Providers.CodeLens.Test
  use ExUnit.Case
  use ExUnitProperties
  doctest GenDSL

  @moduletag timeout: :infinity

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

  # test "Parsing App Element" do
  #   baseline_element = TestHelpers.read_blueprint(@app)["generable_elements"] |> List.last()

  #   generated_element =
  #     GenDSL.Parser.read_blueprint(@app)["generable_elements"]
  #     |> GenDSL.Parser.process_blueprint()
  #     |> List.last()

  #   baseline_element
  #   |> Map.keys()
  #   |> Enum.each(fn key ->
  #     case key do
  #       "type" ->
  #         assert true

  #       "database" ->
  #         assert generated_element |> Map.fetch!(key |> String.to_atom()) |> Atom.to_string() ==
  #                  baseline_element[key]

  #       _ ->
  #         assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
  #     end
  #   end)
  # end

  # test "Parsing App Plugin Element" do
  #   baseline_element =
  #     TestHelpers.read_blueprint(@app_plugin)["generable_elements"] |> List.last()

  #   generated_element =
  #     GenDSL.Parser.read_blueprint(@app_plugin)["generable_elements"] |> List.last()

  #   baseline_element
  #   |> Map.keys()
  #   |> Enum.each(fn key ->
  #     case key do
  #       "type" ->
  #         assert true

  #       "database" ->
  #         assert generated_element |> Map.fetch!(key |> String.to_atom()) |> Atom.to_string() ==
  #                  baseline_element[key]

  #       _ ->
  #         assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
  #     end
  #   end)
  # end

  # test "Parsing Cert Element" do
  #   assert_single_element(@cert)
  # end

  # test "Parsing Channel Element" do
  #   assert_single_element(@channel)
  # end

  # test "Parsing Notifier Element" do
  #   assert_single_element(@notifier)
  # end

  # test "Parsing Presence Element" do
  #   assert_single_element(@presence)
  # end

  # test "Parsing Schema and SchemaField Elements" do
  #   baseline_element = TestHelpers.read_blueprint(@schema)["generable_elements"] |> List.last()
  #   generated_element = GenDSL.Parser.read_blueprint(@schema)["generable_elements"] |> List.last()

  #   baseline_element
  #   |> Map.keys()
  #   |> Enum.each(fn key ->
  #     case key do
  #       "type" ->
  #         assert true

  #       "fields" ->
  #         assert_schema_fields_equal(baseline_element, generated_element)

  #       _ ->
  #         assert generated_element |> Map.fetch!(key |> String.to_atom()) == baseline_element[key]
  #     end
  #   end)
  # end

  describe "process_blueprint/1" do
    property "StreamData generated map is valid gen_dsl" do
      check(
        all(
          blueprint <-
            app = TestHelpers.generate_app(),
          # |> StreamData.unshrinkable(),
          schema <-
            TestHelpers.generate_schema(2, blueprint["arguments"].path),
          auth <-
            TestHelpers.generate_auth(blueprint["arguments"].path),
          cert <-
            TestHelpers.generate_cert(blueprint["arguments"].path),
          channel <-
            TestHelpers.generate_channel(blueprint["arguments"].path),
          embedded <-
            TestHelpers.generate_embedded(blueprint["arguments"].path),
          html <-
            TestHelpers.generate_html(blueprint["arguments"].path),
          max_runs: 1
        )
      ) do
        # IO.inspect(blueprint)
        cwd = File.cwd()
        app = GenDSL.Model.App.to_task(blueprint)
        auth = GenDSL.Model.Auth.to_task(auth)
        cert = GenDSL.Model.Cert.to_task(cert)
        channel = GenDSL.Model.Channel.to_task(channel)
        embedded = GenDSL.Model.Embedded.to_task(embedded)
        html = GenDSL.Model.Html.to_task(html)

        app["arguments"] |> app["callback"].()

        try do
          property_map =
            TestHelpers.generate_property_map(app["arguments"], blueprint.type)

          assert TestHelpers.analyze_project(
                   app["arguments"].path |> Path.basename(),
                   property_map,
                   app["arguments"] |> Map.fetch!(:umbrella)
                 )

          case File.cd(app["arguments"].path) do
            :ok ->
              IO.puts("Changed directory")

            {:error, reason} ->
              IO.puts("Could not change directory: #{reason}")
              raise "Could not change directory"
          end

          Mix.shell().cmd("mix deps.get")
          Mix.shell().cmd("mix compile")
          auth["arguments"] |> auth["callback"].()
          cert["arguments"] |> cert["callback"].()
          channel["arguments"] |> channel["callback"].()
          embedded["arguments"] |> embedded["callback"].()
          html["arguments"] |> html["callback"].()
        rescue
          e ->
            IO.inspect(e)
        end

        File.cd!("../..")

        IO.puts("Generated Property Map")
        # IO.inspect(property_map)

        random_sufix =
          :crypto.strong_rand_bytes(8)
          |> Base.encode64(padding: false)
          |> binary_part(0, 8)
          |> String.replace("/", "")
          |> String.replace("+", "")
          |> String.replace(".", "")

        new_path = app["arguments"].path <> random_sufix
        IO.inspect(new_path, label: "new_path")

        # case File.rename(app["arguments"].path, new_path) do
        #   :ok ->
        #     IO.puts("Renamed app")

        #   {:error, reason} ->
        #     IO.puts("Could not rename app: #{reason}")
        #     raise "Could not rename app"
        # end

        # IO.inspect(schema, label: "schema")
        # IO.inspect(auth, label: "auth")
        # IO.inspect(cert, label: "cert")
        # IO.inspect(channel, label: "channel")
        # IO.inspect(embedded, label: "embedded")
        # IO.inspect(html, label: "html")

        # property_map_is_empty = property_map |> Map.keys() |> Enum.empty?()

        # if property_map_is_empty do
        # File.rm_rf!(new_path)
        # end
      end
    end
  end
end
