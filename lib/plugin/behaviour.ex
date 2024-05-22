defmodule GenDSL.Plugin do

  @callback to_task(arg :: any) :: %{arguments: any, callback: fun()} # The keys should be strings not atoms, if I can't fix that => Change to_task/1 funs and the parser
end
