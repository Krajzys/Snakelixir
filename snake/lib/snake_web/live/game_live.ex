defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view
  require Logger
  alias Model.Snake
  alias Model.Board
  alias Model.Point

  @field_size 20

  def mount(_params, _session, socket) do
    :timer.send_interval(250, :tick)
    {:ok,
    assign(socket, :board, Board.new(width: 20, height: 20, snakes: [
        Snake.new(name: "snake-a", points: [Point.new(coordinates: {5, 5}), Point.new(coordinates: {5, 6}), Point.new(coordinates: {5, 7}), Point.new(coordinates: {6, 7}), Point.new(coordinates: {7, 7})]),
        Snake.new(name: "snake-b", points: [Point.new(coordinates: {10, 5}), Point.new(coordinates: {10, 6}), Point.new(coordinates: {10, 7}), Point.new(coordinates: {9, 7}), Point.new(coordinates: {9, 8})])
      ], apples: [Point.new_apple(20, 20, [])]))
    }
  end

  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keystroke">
      <section class="phx-hero">
        <svg width="400" height="400">
          <%= render_board(assigns) %>
          <%= render_snake(assigns) %>
          <%= render_apple(assigns) %>
        </svg>
      </section>
    </div>
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
      <%= for point <- snake.points do %>
        <% {x, y} = point.coordinates %>
        <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:
        <%= if snake.name == "snake-a" do %>
          rgb(200,100,100);
        <% else %>
          rgb(100,200,100);
        <% end %>
          " />
      <% end %>
    <% end %>
    """
  end

  # TODO: implement this
  defp render_apple(assigns) do
    field_size = @field_size

    ~L"""
    <%= for apple <- assigns.board.apples do %>
      <% {x, y} = apple.coordinates %>
    <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:red"/>
    <% end %>
    """
  end

  def handle_info(:tick, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_a = Snake.move_direction(snake_a)
    snake_b = Snake.move_direction(snake_b)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  # Works for now, but please rewrite it
  def handle_event("keystroke", %{"key" => "ArrowRight"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_a = Snake.change_direction(snake_a, :right)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "ArrowUp"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_a = Snake.change_direction(snake_a, :up)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "ArrowLeft"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_a = Snake.change_direction(snake_a, :left)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "ArrowDown"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_a = Snake.change_direction(snake_a, :down)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end


  def handle_event("keystroke", %{"key" => "d"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_b = Snake.change_direction(snake_b, :right)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "w"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_b = Snake.change_direction(snake_b, :up)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "a"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_b = Snake.change_direction(snake_b, :left)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "s"}, socket) do
    assigns = socket.assigns
    board = assigns.board
    [snake_a, snake_b] = board.snakes
    snake_b = Snake.change_direction(snake_b, :down)
    new_snakes = [snake_a, snake_b]
    board = %{board | snakes: new_snakes}
    {:noreply, socket |> assign(:board, board)}
  end
end
