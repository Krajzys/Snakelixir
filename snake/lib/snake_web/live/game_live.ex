defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view
  require Logger
  alias Model.Snake
  alias Model.Board
  alias Model.Point

  @field_size 20

  def mount(_params, _session, socket) do
    :timer.send_interval(500, :tick)
    {:ok,
    assign(socket, %{board: Logic.GameLoop.init_game(20, 20, "snake-1", "snake-2"), fireballs: [Point.new_fireball({4, 4}, fn x -> x end, 1)]})
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
          <%= render_fireball(assigns) %>
        </svg>
      </section>
    </div>
    <pre>
      <%= inspect assigns.board.snakes %>
    </pre>
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
        <%= if snake.name == "snake-1" do %>
          Teal
        <% else %>
          OliveDrab
        <% end %>
          " />
      <% end %>
    <% end %>
    """
  end

  defp render_apple(assigns) do
    field_size = @field_size

    ~L"""
    <%= for apple <- assigns.board.apples do %>
      <% {x, y} = apple.coordinates %>
    <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:Gold"/>
    <% end %>
    """
  end

  defp render_fireball(assigns) do
    field_size = @field_size

    ~L"""
    <%= for fireball <- assigns.fireballs do %>
      <% {x, y} = fireball.coordinates %>
    <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:Red"/>
    <% end %>
    """
  end

  def handle_info(:tick, socket) do
    # [snake_a, snake_b] = socket.assigns.board.snakes
    # moved_snakes = [snake_a |> Snake.move_direction, snake_b |> Snake.move_direction]
    moved_snakes = Logic.GameLoop.game_loop(socket)
    board = %{socket.assigns.board | snakes: moved_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  # Input handling

  def handle_event("keystroke", %{"key" => "l"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 1 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 1 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:right) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "i"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 1 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 1 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:up) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "j"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 1 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 1 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:left) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "k"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 1 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 1 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:down) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  # Snake id 2

  def handle_event("keystroke", %{"key" => "d"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 2 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 2 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:right) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "w"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 2 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 2 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:up) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "a"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 2 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 2 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:left) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end

  def handle_event("keystroke", %{"key" => "s"}, socket) do
    snakes_list = socket.assigns.board.snakes

    this_snake = Enum.filter(snakes_list, fn snake -> snake.id == 2 end)
    other_snakes = Enum.filter(snakes_list, fn snake -> snake.id != 2 end)
    this_snake = Enum.map(this_snake, fn snake -> snake |> Snake.change_direction(:down) end)

    board = %{socket.assigns.board | snakes: this_snake ++ other_snakes}

    {:noreply, socket |> assign(:board, board)}
  end
end
