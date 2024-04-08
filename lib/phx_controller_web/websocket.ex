defmodule PhxControllerWeb.Websocket do
  require Logger
  @behaviour Phoenix.Socket.Transport

  def child_spec(_opts) do
    # We won't spawn any process, so let's ignore the child spec
    :ignore
  end

  def connect(state) do
    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    {:ok, state}
  end

  def init(state) do
    # Now we are effectively inside the process that maintains the socket.
    {:ok, %{state | "drone_states" => []}}
  end

  def handle_in({text, _opts}, state) do
    raw_data = Jason.decode(text)

    case raw_data do
      {:ok, %{"ping" => "pong"}} ->
        {:reply, :ok, {:text, "pong"}, state}

      {:ok, %{"event" => "update", "data" => data}} ->


        {:reply, :ok, {:text, ""}, %{state| "drone_states" => state["drone_states"] ++ [data] }}

      {:error, error} ->
        Logger.error(error)

      _ ->
        {:reply, :ok, {:text, text}, state}
    end
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
