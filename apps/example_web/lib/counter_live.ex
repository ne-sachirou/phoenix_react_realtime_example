defmodule ExampleWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns), do: ExampleWeb.CounterView.render("counter.html", assigns)

  def mount(%{}, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :count_up)
    {:ok, assign(socket, :count, 0)}
  end

  def handle_info(:count_up, socket) do
    count = socket.assigns.count + 1
    {:noreply, assign(socket, :count, count)}
  end
end
