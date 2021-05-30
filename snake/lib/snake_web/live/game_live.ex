defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view
  require Logger
  alias Model.Snake
  alias Model.Board
  alias Model.Point

  @field_size 20

  def mount(_params, _session, socket) do
    :timer.send_interval(1000, :tick)
    {:ok,
      assign(socket, %{game_state: Logic.GameLoop.init_game(20, 20, "snake-1", "snake-2")})
    }
  end

  # TODO: Przytrzymac ostatnia klatke przez 1-2 sec zeby widoczne byly faile
  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keystroke">
      <section class="phx-hero">
        <svg width="400" height="400">
          <%= if assigns.game_state.status != :game_over do %>
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
      <%= inspect assigns.game_state.status %>
    </pre>
    """
  end

  defp render_game_over(assigns) do
    field_size = @field_size
    ~L"""
    <rect width="<%= assigns.game_state.board.width * field_size %>" height="<%= assigns.game_state.board.height * field_size %>" style="fill:black" />
    <text x="25" y="100" font-size="70" style="fill:white">Game over</text>
    <text x="18" y="200" font-size="40" style="fill:white">Press F5 to try again</text>
    """
  end

  defp render_board(assigns) do
    field_size = @field_size
    ~L"""
    <rect width="<%= assigns.game_state.board.width * field_size %>" height="<%= assigns.game_state.board.height * field_size %>" style="fill:rgb(25,25,25);stroke-width:3;stroke:rgb(255,255,255)" />
    """
  end

  defp render_snake(assigns) do
    field_size = @field_size

    ~L"""
    <%= for {_snake_name, snake_data} <- assigns.game_state.snake_map do %>
      <%= for {point, no} <- Enum.zip(snake_data.snake.points, 0..(length(snake_data.snake.points)-1)) do %>
        <% {x, y} = point.coordinates %>
        <% r_color_number = if rem(div(no*40, 200), 2) == 1, do: rem(no*40, 200), else: 200-rem(no*40, 200) %>
        <% magic_number = if rem(div(no*2, 4), 2) == 1, do: rem(no*2, 4), else: 4-rem(no*2, 4) %>
        <% magic_number = abs(magic_number - 4) %>
          <rect width="<%= field_size - magic_number %>" height="<%= field_size - magic_number %>"
          x="<%= x * field_size + magic_number/2 %>" y="<%= y * field_size + magic_number/2 %>"
          style="fill:
          <%= if snake_date.snake.name == "snake-1" do %>
            rgb(<%= r_color_number %>,200,120);stroke-width:<%= 2 + magic_number/2 %>;stroke:rgb(<%= r_color_number %>,120,80)
          <% else %>
            rgb(<%= r_color_number %>,120,200);stroke-width:<%= 2 + magic_number/2 %>;stroke:rgb(<%= r_color_number %>,80,120)
          <% end %>
            " />
      <% end %>
    <% end %>
    """
  end

  defp render_apple(assigns) do
    field_size = @field_size
    ~L"""
    <%= for apple <- assigns.game_state.apples do %>
      <% {x, y} = apple.coordinates %>
    <circle r="<%= field_size/2 %>"
            cx="<%= x * field_size + field_size/2 %>" cy="<%= y * field_size + field_size/2 %>"
            style="fill:Red;stroke-width:2;stroke:Maroon"/>
    <circle r="<%= field_size/8 %>"
            cx="<%= x * field_size + 4*field_size/6 %>" cy="<%= y * field_size + field_size/3 %>"
            style="fill:White"/>
    <ellipse cx="<%= x * field_size + 4*field_size/5 %>" cy="<%= y * field_size + field_size/8 %>"
            rx="<%= field_size/4 %>" ry="<%= field_size/7 %>"
            style="fill:green;stroke:DarkGreen;stroke-width:2" />
    <ellipse cx="<%= x * field_size + field_size/3 %>" cy="<%= y * field_size + field_size/8 %>"
            rx="<%= field_size/3 %>" ry="<%= field_size/7 %>"
            style="fill:green;stroke:DarkGreen;stroke-width:2" />
    <% end %>
    """
  end

  defp render_fireball(assigns) do
    field_size = @field_size

    ~L"""
    <%= for fireball <- assigns.game_state.fireballs do %>
      <% {x, y} = fireball.coordinates %>
    <circle r="<%= field_size/2 %>"
        cx="<%= x * field_size + field_size/2 %>" cy="<%= y * field_size + field_size/2 %>"
        style="fill:DodgerBlue;stroke-width:2;stroke:rgb(50, 93, 129)"/>
    <circle r="<%= field_size/3 %>"
        cx="<%= x * field_size + field_size/2 %>" cy="<%= y * field_size + field_size/2 %>"
        style="fill:SteelBlue;stroke-width:2;stroke:SteelBlue"/>
    <circle r="<%= field_size/5 %>"
        cx="<%= x * field_size + field_size/2 %>" cy="<%= y * field_size + field_size/2 %>"
        style="fill:White;stroke-width:2;stroke:SkyBlue"/>
    <% end %>
    """
  end

  def handle_info(:tick, socket) do
    game_state = Logic.GameLoop.game_loop(socket)
    # board = %{socket.assigns.board | snakes: moved_snakes}
    # board = %{board | apples: new_apples}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  # Input handling

  # Snake id 2
  # TODO: Shooting on 'u', dash on 'o'

  def handle_event("keystroke", %{"key" => "l"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_1 = snake_map.snake_1
    snake_1 = %{snake_1 | new_direction: :right}
    snake_map = %{snake_map | snake_1: snake_1}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "i"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_1 = snake_map.snake_1
    snake_1 = %{snake_1 | new_direction: :up}
    snake_map = %{snake_map | snake_1: snake_1}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "j"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_1 = snake_map.snake_1
    snake_1 = %{snake_1 | new_direction: :left}
    snake_map = %{snake_map | snake_1: snake_1}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "k"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_1 = snake_map.snake_1
    snake_1 = %{snake_1 | new_direction: :down}
    snake_map = %{snake_map | snake_1: snake_1}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  # Snake id 2
  # TODO: Shooting on 'q', dash on 'e'

  def handle_event("keystroke", %{"key" => "d"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_2 = snake_map.snake_2
    snake_2 = %{snake_2 | new_direction: :right}
    snake_map = %{snake_map | snake_2: snake_2}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "w"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_2 = snake_map.snake_2
    snake_2 = %{snake_2 | new_direction: :up}
    snake_map = %{snake_map | snake_2: snake_2}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "a"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_2 = snake_map.snake_2
    snake_2 = %{snake_2 | new_direction: :left}
    snake_map = %{snake_map | snake_2: snake_2}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end

  def handle_event("keystroke", %{"key" => "s"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_2 = snake_map.snake_2
    snake_2 = %{snake_2 | new_direction: :down}
    snake_map = %{snake_map | snake_2: snake_2}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end
end
