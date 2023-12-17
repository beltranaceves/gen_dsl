defmodule GenDSL.Model do
  def filter_model(model) do
    model
    |> Map.filter(fn {_key, value} -> not is_nil(value) end)
  end

  def get_valid_flags(flags, model) do
    flags
    |> Enum.filter(fn flag ->
      model
      |> then(fn model ->
        Map.has_key?(model, flag) and model |> Map.fetch!(flag)
      end)
    end)
    |> Enum.map(fn flag ->
      "--#{flag |> Atom.to_string() |> String.replace("_", "-")}"
    end)
  end

  def get_valid_named_arguments(named_arguments, model) do
    named_arguments
    |> Enum.filter(fn named_argument ->
      model |> Map.has_key?(named_argument)
    end)
    |> Enum.map(fn named_argument ->
      [
        "--#{named_argument |> Atom.to_string() |> String.replace("_", "-")}",
        model
        |> Map.fetch!(named_argument)
        |> then(fn named_argument_value ->
          case is_atom(named_argument_value) do
            true -> Atom.to_string(named_argument_value)
            _ -> named_argument_value
          end
        end)
      ]
    end)
  end

  def validate_model(model, flags, named_arguments) do
    filtered_model =
      model
      |> filter_model()

    valid_flags =
      flags
      |> get_valid_flags(filtered_model)

    valid_named_arguments =
      named_arguments
      |> get_valid_named_arguments(filtered_model)

    [
      valid_flags,
      valid_named_arguments,
      filtered_model
    ]
  end
end
