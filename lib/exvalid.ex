defmodule ExValid do
  defmacro __using__(opts \\ []) do
    quote do
      use Witchcraft, unquote(opts)
      alias ExValid.Validate
    end
  end
end
