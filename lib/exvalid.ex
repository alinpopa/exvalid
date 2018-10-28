defmodule ExValid do
  defmacro __using__(opts \\ []) do
    quote do
      use Witchcraft, unquote(opts)
      alias ExValid.Validate
      alias ExValid.Async.Validate, as: AsyncValidate
    end
  end
end
