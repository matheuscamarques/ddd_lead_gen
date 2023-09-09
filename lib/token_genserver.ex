defmodule TokenGenserver do
    use GenServer

    def start_link(init_args \\ []) do
        # you may want to register your server with `name: __MODULE__`
        # as a third argument to `start_link`
        GenServer.start_link(__MODULE__, [init_args], name: __MODULE__)
    end

    def init(_args) do
        {:ok, nil}
    end

    def handle_cast({:set_token, token}, _state) do
        {:noreply, token}
    end

    def set_token(token) do
        GenServer.cast(__MODULE__, {:set_token, token})
    end

    def handle_call(:get_token, _from, state) do
        {:reply, state, state}
    end

    def get_token() do
        GenServer.call(__MODULE__, :get_token)
    end
end