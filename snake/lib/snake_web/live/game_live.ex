defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view
  alias Model.Snake
  alias Model.Board

  @field_size 20

  def mount(_params, _session, socket) do
    :timer.send_interval(500, :tick)
    {:ok,
    assign(socket, :board, Board.new(width: 20, height: 20, snakes: [
        Snake.new(name: "snake-a", points: [{5, 5}, {5, 6}, {5, 7}, {6, 7}, {7, 7}]),
        Snake.new(name: "snake-b", points: [{10, 5}, {10, 6}, {10, 7}, {9, 7}, {9, 8}])
      ]))
    }
  end

  def render(assigns) do
    ~L"""
    <section class="phx-hero">
      <svg width="400" height="400">
        <%= render_board(assigns) %>
        <%= render_snake(assigns) %>
      </svg>
    </section>
    """
  end

  defp render_board(assigns) do
    field_size = @field_size
    ~L"""
    <rect width="<%= assigns.board.width * field_size %>" height="<%= assigns.board.height * field_size %>" style="fill:rgb(25,25,25);stroke-width:3;stroke:rgb(255,255,255)" />
    """
  end

  defp render_snake(assigns) do
    field_size = @field_size

    ~L"""
    <%= for snake <- assigns.board.snakes do %>
      <%= for {x, y} <- snake.points do %>
        <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:
        <%= if snake.name == "snake-a" do %>
          rgb(200,100,100);
        <% else %>
          rgb(100,200,100);
        <% end %>
        stroke-width:3;stroke:rgb(255,255,255)" />
      <% end %>
    <% end %>
    """
  end

  # TODO: implement this
  defp render_apple(assigns) do
    ~L"""
    """
  end

  def handle_info(:tick, socket) do
    {:noreply, socket}
  end
end
