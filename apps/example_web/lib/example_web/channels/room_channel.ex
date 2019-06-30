defmodule ExampleWeb.RoomChannel do
  use ExampleWeb, :channel

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :count, 0)
      :timer.send_interval(1000, self(), :count_up)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  def handle_info(:count_up, socket) do
    count = socket.assigns.count + 1
    socket = assign(socket, :count, count)
    push(socket, "count_up", %{count: count})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
