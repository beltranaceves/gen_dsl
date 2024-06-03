defmodule GenDSL.Parser do
  @moduledoc "Module to parse_blueprint custom DSL"

  @file_path "sample_blueprint.ex"
  @sections ~w(dependencies app pretasks generable_elements posttasks)s
  @accepted_keys ~w(app dependencies pretasks generable_elements posttasks)a
  @accepted_strings ~w(app dependencies pretasks generable_elements posttasks)s

  # TODO: remove @file_path default value
  def read_blueprint(blueprint_path \\ @file_path) do
    case File.read(blueprint_path) do
      {:ok, body} -> {:ok, parse_blueprint(body)}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_blueprint(blueprint) do
    IO.puts("Parsing blueprint")
    parse_blueprint = Jason.decode!(blueprint)
    IO.inspect(parse_blueprint, label: "Parsed blueprint")
    parse_blueprint
  end

  def process_blueprint(blueprint) do
    IO.puts("Processing blueprint")

    blueprint
    |> Map.keys()
    |> Enum.map(fn section_key ->
      {section_key, process_section(blueprint[section_key], section_key)}
    end)
    |> Enum.into(%{})
  end

  def execute_blueprint(blueprint, get_deps) do
    IO.puts("Executing blueprint")

    # TODO: check if this loads all plugins
    Mix.Task.load_all()

    # blueprint
    # |> Map.keys()
    # |> Enum.each(fn section_key ->
    #   execute_section(blueprint[section_key], section_key)
    # end)
    # IO.inspect(blueprint, label: "Blueprint")
    @sections
    |> Enum.each(fn section ->
      if Map.has_key?(blueprint, section) do
        case section do
          "dependencies" -> execute_section(blueprint[section], section, get_deps)
          _ -> execute_section(blueprint[section], section)
        end
      end
    end)
  end

  def process_section(section, "dependencies" = _type) do
    section
    |> Enum.map(fn depenency ->
      {depenency["package"] |> String.to_atom(), depenency["version"]}
    end)
  end

  def process_section(section, "app" = _type) do
    IO.puts("Processing App")

    element_tasks =
      to_callbacks(section)

    element_tasks
  end

  def process_section(section, "pretasks" = _type) do
    IO.puts("Processing pretasks")

    element_tasks =
      section
      |> Enum.map(fn generable_element ->
        to_callbacks(generable_element)
      end)

    element_tasks
  end

  def process_section(section, "generable_elements" = _type) do
    IO.puts("Processing generable elements")

    element_tasks =
      section
      |> Enum.map(fn generable_element ->
        to_callbacks(generable_element)
      end)

    element_tasks
  end

  def process_section(section, "posttasks" = _type) do
    IO.puts("Processing posttasks")
    post_tasks =
      section
      |> Enum.map(fn post_task ->
        to_callbacks(post_task)
      end)

    post_tasks
  end

  def process_section(_section, _type) do
    []
  end

  # TODO: Add support for all section types
  def execute_section(section, "dependencies" = _type, get_deps) do
    IO.puts("Installing dependencies")

    if get_deps do
      section
      |> Mix.install(consolidate_protocols: true)
    end
  end

  def execute_section(section, "app" = _type) do
    apply(
      section["callback"],
      [
        section["arguments"]
      ]
    )
  end

  def execute_section(section, "pretasks" = _type) do
    section
    # TODO: encapsulate this in a private function
    |> Enum.each(fn generable_element ->
      apply(
        generable_element["callback"],
        [
          generable_element["arguments"]
        ]
      )
    end)
  end

  def execute_section(section, "generable_elements" = _type) do
    section
    # TODO: encapsulate this in a private function
    |> Enum.each(fn generable_element ->
      apply(
        generable_element["callback"],
        [
          generable_element["arguments"]
        ]
      )
    end)
  end

  def execute_section(section, "posttasks" = _type) do
    section
    |> Enum.each(fn post_task ->
      apply(
        post_task["callback"],
        [
          post_task["arguments"]
        ]
      )
    end)

  end

  defp to_callbacks(element) do
    apply(
      String.to_existing_atom("Elixir.GenDSL.Model." <> element["type"]),
      :to_task,
      [
        element
      ]
    )
  end

  def sanitize_blueprint(blueprint) do
    Map.take(blueprint, @accepted_keys ++ @accepted_strings)
    |> Jason.encode!()
    |> Jason.decode!(keys: :strings)
  end

  def add_prerequisites(tasks) do
    prerequisites = %{
      "pretasks" => [
        %{
          "type" => "Hex"
        }
      ]
    }

    tasks
    |> Map.merge(prerequisites)
  end

  def add_postrequisites(tasks, original_dir \\ nil) do
    prerequisites = %{
      "posttasks" => [
        %{
          "type" => "ReturnDir",
          "dir" => original_dir
        }
      ]
    }

    tasks
    |> Map.merge(prerequisites)
  end
end
