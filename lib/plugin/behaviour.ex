defmodule GenDSL.Plugin.Behaviour do
  @callback get_element_task() :: fun()
end
