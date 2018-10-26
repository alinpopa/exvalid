alias ExValid.Validate.{Valid, Invalid}
import TypeClass
use Witchcraft

defmodule ExValid.Validate do
  defmodule Valid do
    defstruct valid: nil

    def new(data), do: %Valid{valid: data}
  end

  defmodule Invalid do
    defstruct invalid: []

    def new(data) when is_list(data), do: %Invalid{invalid: data}
    def new(data), do: %Invalid{invalid: [data]}
  end
end

defimpl TypeClass.Property.Generator, for: Invalid do
  def generate(_) do
    [1, 1.1, "", [], ?a]
    |> Enum.random()
    |> TypeClass.Property.Generator.generate()
    |> Invalid.new()
  end
end

defimpl TypeClass.Property.Generator, for: Valid do
  def generate(_) do
    [1, 1.1, "", [], ?a]
    |> Enum.random()
    |> TypeClass.Property.Generator.generate()
    |> Valid.new()
  end
end

definst Witchcraft.Functor, for: Invalid do
  def map(invalid, _), do: invalid
end

definst Witchcraft.Functor, for: Valid do
  def map(%Valid{valid: data}, fun), do: data |> fun.() |> Valid.new()
end

definst Witchcraft.Apply, for: Invalid do
  def convey(invalid = %Invalid{}, %Valid{}), do: invalid

  def convey(%Invalid{invalid: e1}, %Invalid{invalid: e2}),
    do: Invalid.new(e1 <> e2)
end

definst Witchcraft.Apply, for: Valid do
  def convey(%Valid{valid: a}, %Valid{valid: fab}),
    do: Valid.new(fab.(a))

  def convey(_, invalid = %Invalid{}), do: invalid
end

definst Witchcraft.Applicative, for: Invalid do
  def of(_, data), do: Valid.new(data)
end

definst Witchcraft.Applicative, for: Valid do
  def of(_, data), do: Valid.new(data)
end

definst Witchcraft.Chain, for: Invalid do
  def chain(invalid, _), do: invalid
end

definst Witchcraft.Chain, for: Valid do
  def chain(%Valid{valid: data}, link), do: link.(data)
end
