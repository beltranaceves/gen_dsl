defmodule GenDSL.Parser do
  @moduledoc "Module to parse custom DSL"

  @file_path "sample_blueprint.ex"

  def read_blueprint(blueprint_path \\ @file_path) do
    case File.read(blueprint_path) do
      {:ok, body} -> parse(body)
      {:error, reason} -> IO.puts(reason)
    end
  end

  def parse(blueprint) do
    IO.puts("Decoding Blueprint")

    elements_changesets =
      Jason.decode!(blueprint)
      |> Enum.map(fn blueprint_map ->
        IO.inspect(blueprint_map)

        apply(String.to_existing_atom("Elixir.GenDSL.Model." <> blueprint_map["type"]), :changeset, [
          blueprint_map
        ])
      end)

    elements =
      elements_changesets
      |> Enum.map(fn changeset ->
        changeset |> Ecto.Changeset.apply_changes()
      end)

    IO.inspect(elements)
    elements
  end

  #   def struct_to_command(element = %:Html{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Schema{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Notifier{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Secret{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Json{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Embedded{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Release{}) do
  #     [element.command]
  #     # ++ element.docker_flag ++ element.no_ecto_flag ++ element.ecto_flag
  #   end

  #   def struct_to_command(element = %:Socket{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Live{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Presence{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Context{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Cert{}) do
  #     IO.puts(element)
  #   end

  #   def struct_to_command(element = %:Auth{}) do
  #     IO.puts(element)
  #   end
end
