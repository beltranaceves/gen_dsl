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

  def execute_blueprint(blueprint) do
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
      execute_section(blueprint[section], section)
    end)
  end

  def process_section(section, type) when type == "dependencies" do
    section
  end

  def process_section(section, type) when type == "app" do
    IO.puts("Processing App")

    element_tasks =
      to_callbacks(section)

    element_tasks
  end

  def process_section(section, type) when type == "pretasks" do
    IO.puts("Processing pretasks")

    element_tasks =
      section
      |> Enum.map(fn generable_element ->
        to_callbacks(generable_element)
      end)

    element_tasks
  end

  def process_section(section, type) when type == "generable_elements" do
    IO.puts("Processing generable elements")

    element_tasks =
      section
      |> Enum.map(fn generable_element ->
        to_callbacks(generable_element)
      end)

    element_tasks
  end

  def process_section(section, type) when type == "posttasks" do
    section
  end

  def process_section(_section, _type) do
    []
  end

  def execute_section(section, type) when type == "app" do
    apply(
      section["callback"],
      [
        section["arguments"]
      ]
    )
  end

  # TODO: Add support for all section types
  def execute_section(section, type) when type == "dependencies" do
    section
    |> Enum.each(fn depenency ->
      Mix.install([{depenency["package"] |> String.to_atom(), depenency["version"]}])
    end)
  end

  def execute_section(section, type) when type == "pretasks" do
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

  def execute_section(section, type) when type == "generable_elements" do
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

  def execute_section(section, type) when type == "posttasks" do
    section
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

  def add_postrequisites(tasks) do
    prerequisites = %{
      "pretasks" => [
        %{
          "type" => "ReturnDir"
        }
      ]
    }

    tasks
    |> Map.merge(prerequisites)
  end
end
