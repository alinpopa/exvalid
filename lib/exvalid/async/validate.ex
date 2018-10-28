alias ExValid.Async.Validate.{Valid, Invalid, Running}
alias ExValid.Async.State
import TypeClass
use Witchcraft

defmodule ExValid.Async.Validate do
  defmodule Valid do
    defstruct valid: nil

    def new(data), do: %Valid{valid: data}
  end

  defmodule Invalid do
    defstruct invalid: []

    def new(data) when is_list(data), do: %Invalid{invalid: data}
    def new(data), do: %Invalid{invalid: [data]}
  end

  defmodule Running do
    defstruct pid: nil, init: nil, timeout: 5000

    def new(data, timeout \\ 5000)

    def new(data, timeout) do
      state(data, timeout)
    end

    defp state(data, timeout) do
      {:ok, pid} = State.start_link(data)
      %Running{pid: pid, init: data, timeout: timeout}
    end
  end

  def new(data, timeout \\ 5000), do: Running.new(data, timeout)
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

definst Witchcraft.Functor, for: Running do
  @force_type_instance true

  def map(%Running{pid: pid, timeout: timeout}, fun) do
    if not Process.alive?(pid) do
      Invalid.new("finished")
    else
      case State.get(pid) do
        {:failure, result} -> Invalid.new(result)
        {:success, result} -> Valid.new(fun.(result))
      end
    end
  end
end

definst Witchcraft.Apply, for: Invalid do
  def convey(%Invalid{invalid: f1}, %Invalid{invalid: f2}), do: Invalid.new(f1 <> f2)
  def convey(invalid, _), do: invalid
end

definst Witchcraft.Apply, for: Valid do
  def convey(_, invalid = %Invalid{}), do: invalid
  def convey(valid, %Valid{valid: fun}), do: map(valid, fun)
end

definst Witchcraft.Apply, for: Running do
  @force_type_instance true

  def convey(running, %Valid{valid: fun}), do: map(running, fun)
  def convey(_, invalid = %Invalid{}), do: invalid
end

definst Witchcraft.Applicative, for: Invalid do
  def of(_, data), do: Valid.new(data)
end

definst Witchcraft.Applicative, for: Valid do
  def of(_, data), do: Valid.new(data)
end

definst Witchcraft.Applicative, for: Running do
  @force_type_instance true

  def of(_, data), do: Valid.new(data)
end

definst Witchcraft.Chain, for: Invalid do
  def chain(invalid, _), do: invalid
end

definst Witchcraft.Chain, for: Valid do
  def chain(%Valid{valid: data}, link), do: link.(data)
end

definst Witchcraft.Chain, for: Running do
  @force_type_instance true

  def chain(%Running{pid: pid, timeout: timeout}, link) do
    if not Process.alive?(pid) do
      Invalid.new("finished")
    else
      case State.get(pid) do
        {:failure, result} -> Invalid.new(result)
        {:success, result} -> link.(result)
      end
    end
  end
end
