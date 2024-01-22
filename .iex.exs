defmodule Testing do

  def walking() do
    IO.puts("Walking")
    ast = Code.string_to_quoted("
    defmodule Foo do
      def bar do
        5 + 3 * 7
      end
    end
    ")
    {:+, _, [5, {:*, _, [3, 7]}]} = ast
    {new_ast, acc} = Macro.prewalk(ast, [], fn
      {:__aliases__, meta, children}, acc ->
        IO.inspect({:__aliases__, meta, children}, label: "Alias")
        {{:__aliases__, meta, children}, [ children |> Enum.at(0) | acc]}
      # {:*, meta, children}, acc -> {{:+, meta, children}, [:* | acc]}
      other, acc -> {other, acc}
      _, acc -> {_, acc}
    end)
    IO.inspect(acc, label: "Accumulator")
  end

end
