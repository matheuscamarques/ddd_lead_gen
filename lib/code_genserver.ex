defmodule CodeGenserver do
  use GenServer

  def start_link(init_args \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
  end

  def init(_args) do
    {:ok, sport} = :gen_tcp.listen(4000, active: true)

    {:ok,
     %{
       port: sport,
       code: nil
     }}
  end

  def handle_info(info, state) do
    case info do
      {:tcp, socket, data} ->
        data_str = List.to_string(data)
        splitted = String.split(data_str, " ")
        [_mehtod, params | _] = splitted
        code = case params do
          nil -> nil
          _ -> String.split(params, "=") |> List.last()
        end

        {:noreply, %{state | code: code}}

      _ ->
        {:noreply, state}
    end
  end

  def handle_call(:await_code, _from, state) do
    {:ok, _} = :gen_tcp.accept(state.port)
    {:reply, :data_received, state}
  end

  def handle_call(:get_code, _from, state) do
    {:reply, state.code, state}
  end

  def await_code() do
    GenServer.call(__MODULE__, :await_code, 60 * 1000 * 60)
  end

  def get_code() do
    GenServer.call(__MODULE__, :get_code)
  end
end
