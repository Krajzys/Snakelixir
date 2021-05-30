defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view
  require Logger
  alias Model.Snake
  alias Model.Board
  alias Model.Point

  @field_size 20

  def mount(_params, _session, socket) do
    :timer.send_interval(100, :tick)
    {:ok,
      assign(socket, %{board: Logic.GameLoop.init_game(20, 20, "snake-1", "snake-2"), fireballs: []})
    }
  end

  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keystroke">
      <section class="phx-hero">
        <svg width="400" height="400">
          <%= if assigns.board.snakes != [] do %>
            <%= render_board(assigns) %>
            <%= render_snake(assigns) %>
            <%= render_apple(assigns) %>
            <%= render_fireball(assigns) %>
          <% else %>
            <%= render_game_over(assigns) %>
          <% end %>
        </svg>
      </section>
    </div>
    <pre>
      <%= inspect assigns.board.snakes %>
    </pre>
    """
  end

  defp render_game_over(assigns) do
    field_size = @field_size
    ~L"""
    <rect width="<%= assigns.board.width * field_size %>" height="<%= assigns.board.height * field_size %>" style="fill:black" />
    <text x="25" y="100" font-size="70" style="fill:white">Game over</text>
    <text x="18" y="200" font-size="40" style="fill:white">Press F5 to try again</text>
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
      <%= for {point, no} <- Enum.zip(snake.points, 0..(length(snake.points)-1)) do %>
        <% {x, y} = point.coordinates %>
        <rect width="<%= field_size %>" height="<%= field_size %>"
        x="<%= x * field_size %>" y="<%= y * field_size %>"
        style="fill:
        <%= if snake.name == "snake-1" do %>
          rgb(<%= no*40 %>,200,120)
        <% else %>
          rgb(<%= no*40 %>,120,200)
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
        style="fill:Red"/>
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
        style="fill:Gold"/>
    <% end %>
    """
  end

  def handle_info(:tick, socket) do
    [moved_snakes, new_apples] = Logic.GameLoop.game_loop(socket)
    board = %{socket.assigns.board | snakes: moved_snakes}
    board = %{board | apples: new_apples}

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
