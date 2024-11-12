defmodule Socket.Websocket do
  use WebSockex
  require Logger

  def start_link(send_to_pid), do: WebSockex.start_link("wss://dev.baseline.vn/cable", __MODULE__, %{send_to_pid: send_to_pid})

  @impl true
  def handle_frame({:text, msg}, %{send_to_pid: pid}=state) do

    Logger.info "Received a message: #{inspect msg}"

    send pid, {:websocket_msg_received, self(), msg}

    # get_data(data)
    {:ok, state}
  end

  def request(client, massage) do
    Logger.info(massage)
    WebSockex.send_frame(client, {:text, massage})

  end

  # @impl true
  # def handle_info(:subscribe, state) do
  #   subscribe =
  #     Jason.encode!(%{
  #       "command" => "subcribe",
  #       "indentifier" => "{\"channel\":\"MatchChannel\",
  #       \"match_id\":\"91e724f0-52d4-432e-9f4e-b4a7904296f4\"}"
  #     })
  #   {:reply, {:text, subscribe}, state}
  # end

  # def get_data(data) do
  #   {:ok, jason} = Jason.decode(data)
  #   WebSockex.send_frame(Jason.encode!(%{"command" => "massage","indentifier" => %{"channel" => "MatchChannel","match_id" => "91e724f0-52d4-432e-9f4e-b4a7904296f4"},"data" => %{"action" => "get_state"}}))
  #   Logger.info(data)
  # end
end
