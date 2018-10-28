defmodule ExValid.Async.State do
  @behaviour :gen_statem

  defmodule S do
    defstruct init: nil, result: nil
  end

  def start_link(data) do
    :gen_statem.start_link(__MODULE__, %S{init: data}, [])
  end

  def get(pid) do
    :gen_statem.call(pid, :get)
  end

  def stop(pid) do
    :gen_statem.stop(pid)
  end

  def init(state) do
    {:ok, :running, state, [{:next_event, :internal, :run}]}
  end

  def callback_mode() do
    :handle_event_function
  end

  def handle_event(:internal, :run, :running, state) do
    case is_function(state.init) do
      true ->
        try do
          result = state.init.()
          {:next_state, :success, %S{state | result: result}}
        rescue
          e ->
            {:next_state, :failure, %S{state | result: e}}
        end

      false ->
        {:next_state, :success, %S{state | result: state.init}}
    end
  end

  def handle_event({:call, from}, :get, :success, state) do
    {:stop_and_reply, :normal, [{:reply, from, {:success, state.result}}]}
  end

  def handle_event({:call, from}, :get, :failure, state) do
    {:stop_and_reply, :normal, [{:reply, from, {:failure, state.result}}]}
  end
end
