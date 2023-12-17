defmodule GenDSL.Parser do
  @moduledoc "Module to parse_blueprint custom DSL"

  @file_path "sample_blueprint.ex"

  def read_blueprint(blueprint_path \\ @file_path) do
    case File.read(blueprint_path) do
      {:ok, body} -> {:ok, parse_blueprint(body)}
      {:error, reason} -> {:error, reason}
    end
  end

  def parse_blueprint(blueprint) do
    IO.puts("Parsing blueprint")

    parse_blueprint = Poison.decode!(blueprint)

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

    blueprint
    |> Map.keys()
    |> Enum.each(fn section_key ->
      execute_section(blueprint[section_key], section_key)
    end)
  end

  def process_section(section, type) when type == "dependencies" do
    section
  end

  def process_section(section, type) when type == "pretasks" do
    section
  end

  def process_section(section, type) when type == "generable_elements" do
    IO.puts("Processing generable elements")

    element_tasks =
      section
      |> Enum.map(fn generable_element ->
        apply(
          String.to_existing_atom("Elixir.GenDSL.Model." <> generable_element["type"]),
          :to_task,
          [
            generable_element
          ]
        )
      end)

    element_tasks
  end

  def process_section(section, type) when type == "posttasks" do
    section
  end

  # TODO: Add support for all section types
  def execute_section(section, type) when type == "dependencies" do
    section
    |> Enum.each(fn depenency ->
      Mix.install(depenency)
    end)
  end

  def execute_section(section, type) when type == "pretasks" do
    section
  end

  def execute_section(section, type) when type == "generable_elements" do
    section
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
end
