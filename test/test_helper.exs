defmodule TestHelpers do
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
end

ExUnit.start()
