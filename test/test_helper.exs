defmodule TestHelpers do
  # use ExUnit.Case
  # use ExUnitProperties

  def read_blueprint(filepath) do
    case File.read(filepath) do
      {:ok, body} -> Poison.decode!(body)
      {:error, reason} -> IO.puts(reason)
    end
  end

  def unique_app_name(app_name) do
    app_name <> (System.unique_integer([:positive, :monotonic]) |> Integer.to_string())
  end

  def generate_property_map(element, "App") do
    properties = %{}

    aliases =
      case element.module do
        nil ->
          case element.app do
            nil ->
              [Path.basename(element.path) |> String.capitalize() |> String.to_atom()]

            _ ->
              [element.app |> String.capitalize() |> String.to_atom()]
          end

        _ ->
          [element.module |> String.replace("Elixir.", "") |> String.to_atom()]
      end

    properties
    |> Map.put("aliases", aliases)
  end

  def analyze_project(project_name, properties, is_umbrella) do
    project_directory = Path.join("test/test_projects", project_name)

    IO.puts("Analyzing project directory: #{project_directory}")

    Path.wildcard(Path.join(project_directory, "lib/**/*.ex"))
    |> Enum.map(fn path ->
      File.read!(path)
      |> analyze_file(properties)
    end)

    IO.puts("Properties")
    IO.inspect(properties)
  end

  # def analyze_file1(file, properties) do
  #   contents =
  #     file
  #     |> Code.string_to_quoted()
  #     |> inspect(pretty: true)

  #   File.write!("./ast.txt", contents)

  #   {ast, remaining_properties} =
  #     Code.string_to_quoted(file)
  #     # |> Macro.expand(__ENV__)
  #     |> Macro.postwalk(fn segment ->
  #       IO.inspect(segment)

  #       properties =
  #         case segment do
  #           {:__aliases__, m, c} ->
  #             # IO.puts("Node with aliases")
  #             # IO.inspect(c)
  #             case properties |> Map.fetch("aliases") do
  #               {:ok, aliases} ->
  #                 if aliases |> Enum.member?(children |> Enum.fetch!(0)) do
  #                   properties
  #                   |> Map.update!(
  #                     "aliases",
  #                     fn aliases ->
  #                       aliases |> Enum.reject(fn alias -> alias == children[0] end)
  #                     end
  #                   )
  #                 end

  #                 {{:__aliases__, m, c}, properties}
  #             end

  #           node, acc ->
  #             IO.puts("Something else")
  #             {node, acc}
  #         end
  #     end)
  # end

  def analyze_file(file, properties) do
    IO.puts("Analyzing file:")

    remaining_properties =
      Code.string_to_quoted(file)
      # |> IO.inspect()
      # |> Macro.expand(__ENV__)
      |> Macro.prewalk(properties, fn
        {:__aliases__, meta, children}, properties ->
          case properties |> Map.fetch("aliases") do
            {:ok, aliases} ->
              IO.puts("Node with aliases")
              IO.inspect(children)

              updated_aliases =
                if aliases |> Enum.member?(children |> Enum.at(0)) do
                  IO.puts("Removing alias")
                  List.delete(aliases, children |> Enum.at(0))
                else
                  aliases
                end

              node_properties =
                properties
                |> Map.update!("aliases", fn aliases -> updated_aliases end)

              {{:__aliases__, meta, children}, node_properties}

            _ ->
              {{:__aliases__, meta, children}, properties}
          end

        {marker, meta, children}, properties ->
          # IO.puts("Node")
          # IO.inspect(marker)
          {{marker, meta, children}, properties}

        # IO.inspect(meta)
        # IO.inspect(children)

        other, properties ->
          # IO.puts("Other")
          # IO.inspect(other)
          {other, properties}
      end)

    IO.puts("Remaining properties")
    IO.inspect(remaining_properties)
    remaining_properties
  end

  def generate_app() do
    # Generate a valid StreamData.optional_map to represent a GenDSL.Model.App struct using StreamData functions
    StreamData.optional_map(
      %{
        type: StreamData.constant("App"),
        path:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 20, max_lenght: 35)
          |> StreamData.map(&("validapp_" <> &1))
          |> StreamData.map(&Path.join("test/test_projects", &1))
          |> StreamData.unshrinkable(),
        # TODO: enable this fields once umbrella projects are supported
        # umbrella: StreamData.boolean(),
        app: StreamData.string(Enum.concat([?a..?z]), min_length: 5, max_lenght: 35),
        module:
          StreamData.atom(:alias)
          |> StreamData.map(&Atom.to_string/1),
        database:
          StreamData.one_of([
            StreamData.constant("postgres"),
            StreamData.constant("mysql"),
            StreamData.constant("mssql"),
            StreamData.constant("sqlite3")
          ]),
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
        verbose: StreamData.boolean()
        # TODO: enable this fields once the mix deps.get bug is fixed
        # install: install_flag = StreamData.boolean(),
        # no_install: install_flag |> StreamData.map(&(!&1)),
      },
      [
        # TODO: enable this field once umbrella projects are supported
        # :umbrella,
        :app,
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
        :verbose
        # :install,
        # :no_install
      ]
    )
  end

  def generate_schema(field_count) do
    # TODO: expand this section to include all datatypes
    fields =
      case field_count do
        0 ->
          []

        _ ->
          for _i <- 1..field_count do
            StreamData.fixed_map(%{
              field_name:
                StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 9)
                |> StreamData.map(&("field_name_" <> &1)),
              datatype: :string
            })
          end
      end

    schema =
      StreamData.optional_map(
        %{
          type: StreamData.constant("Schema"),
          module:
            StreamData.atom(:alias)
            |> StreamData.map(&Atom.to_string/1),
          name:
            StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 9)
            |> StreamData.map(&("table_name_" <> &1)),
          table:
            StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 9)
            |> StreamData.map(&("table_name_" <> &1)),
          # repo: # TODO: find a way to make the repo field work with the app module
          # migration_dir: # TODO: find a way to make the migration_dir field work with the correct subdirectory path
          prefix:
            StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 5, max_lenght: 9)
            |> StreamData.map(&("schema_prefix_" <> &1)),
          binary_id: StreamData.boolean(),
          fields: StreamData.fixed_list(fields)
        },
        [
          :table,
          :prefix,
          :binary_id
        ]
      )
  end

  def generate_auth() do
    # Generate a valid StreamData.optional_map to represent a GenDSL.Model.App struct using StreamData functions
    StreamData.optional_map(
      %{
        type: StreamData.constant("Auth"),
        context:
          StreamData.atom(:alias)
          |> StreamData.map(&Atom.to_string/1),
        web:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 3, max_lenght: 9)
          |> StreamData.map(&("web_" <> &1)),
        hashing_lib:
          StreamData.one_of([
            StreamData.constant("bcrypt"),
            StreamData.constant("pbkdf2"),
            StreamData.constant("argon2")
          ]),
        binary_id: StreamData.boolean(),
        schema: generate_schema(0)
      },
      [
        :web,
        :hashing_lib,
        :binary_id
      ]
    )
  end

  def generate_cert() do
    # Generate a valid StreamData.optional_map to represent a GenDSL.Model.App struct using StreamData functions
    StreamData.optional_map(
      %{
        type: StreamData.constant("Cert"),
        app:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 3, max_lenght: 9)
          |> StreamData.map(&("app_" <> &1)),
        domain:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 3, max_lenght: 9)
          |> StreamData.map(&("domain_" <> &1)),
        url:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 3, max_lenght: 9)
          |> StreamData.map(&("www." <> &1 <> ".com")),
        name:
          StreamData.string(Enum.concat([?a..?z, ?1..?9]), min_length: 3, max_lenght: 9)
          |> StreamData.map(&("cert_" <> &1)),
        # output: # TODO: find a way to make the output field work with the correct subdirectory path
      },
      [
        :app,
        :domain,
        :url,
        :name
      ]
    )
  end
end

ExUnit.start()
