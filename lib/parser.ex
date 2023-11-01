defmodule GenDSL.Parser do
  @moduledoc "Module to parse_blueprint custom DSL"

  @file_path "sample_blueprint.ex"

  def read_blueprint(blueprint_path \\ @file_path) do
    case File.read(blueprint_path) do
      {:ok, body} -> parse_blueprint(body)
      {:error, reason} -> IO.puts(reason)
    end
  end

  def parse_blueprint(bluepring) do
    IO.puts("Parsing blueprint")

    parsed_sections = Poison.decode!(blueprint)
    parsed_sections |> Enum.each(fn parsed_section ->
      process_section(parsed_section)
    end)
  end

  def parse_blueprint(blueprint) do
    IO.puts("Decoding Blueprint")

    elements_changesets =
      Poison.decode!(blueprint)
      |> Enum.map(fn blueprint_map ->
        IO.inspect(blueprint_map)

        apply(
          String.to_existing_atom("Elixir.GenDSL.Model." <> blueprint_map["type"]),
          :changeset,
          [
            blueprint_map
          ]
        )
      end)

    elements =
      elements_changesets
      |> Enum.map(fn changeset ->
        changeset |> Ecto.Changeset.apply_changes()
      end)

    IO.inspect(elements)
    elements
  end

  def process_section(section) when section.type == "dependencies" do
    section.dependencies
    |> Enum.each(fn depenency ->
      Mix.install(depenency)
    end)
  end

  def process_section(section) when section.type == "pretasks" do

  end

  def process_section(section) when section.type == "generable_elements" do

  end

  def process_section(section) when section.type == "posttasks" do

  end

end
