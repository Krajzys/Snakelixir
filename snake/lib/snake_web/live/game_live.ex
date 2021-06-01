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
      assign(socket, %{game_state: Logic.GameLoop.init_game(20, 20, "snake-1", "snake-2")})
    }
  end

  # TODO: Przytrzymac ostatnia klatke przez 1-2 sec zeby widoczne byly faile
  def render(assigns) do
    ~L"""
    <div phx-window-keydown="keystroke">
      <section class="phx-hero">
        <svg width="100" height="400">
        <%= render_score(assigns, 0) %>
        </svg>
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
        <svg width="100" height="400">
        <%= render_score(assigns, 1) %>
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
    color_1 = "rgb(80,200,120)"
    color_2 = "rgb(80,120,200)"

    ~L"""
    <defs>
      <linearGradient id="BoardStroke" x1="0" x2="1" y1="0" y2="0">
          <stop offset="0%" stop-color="rgb(80,200,120)"/>
          <stop offset="100%" stop-color="rgb(80,120,200)"/>
      </linearGradient>
    </defs>
    <rect width="<%= assigns.game_state.board.width * field_size %>" height="<%= assigns.game_state.board.height * field_size %>" style="fill:black;stroke-width:3;stroke:url(#BoardStroke)" />
    <text text-anchor="middle" x="200" y="100" font-size="70" style="fill:white">Game over</text>
    <text text-anchor="middle" x="200" y="200" font-size="40" style="fill:white">Press F5 to try again</text>

    <text text-anchor="middle" x="70" y="280" font-size="10" style="fill:white">fireball</text>
    <text text-anchor="middle" x="100" y="280" font-size="10" style="fill:white">up</text>
    <text text-anchor="middle" x="100" y="300" font-size="30" style="fill:<%= color_1 %>">q w e</text>
    <text text-anchor="middle" x="70" y="330" font-size="10" style="fill:white">left</text>
    <text text-anchor="middle" x="100" y="330" font-size="10" style="fill:white">down</text>
    <text text-anchor="middle" x="130" y="330" font-size="10" style="fill:white">right</text>
    <text text-anchor="middle" x="100" y="350" font-size="30" style="fill:<%= color_1 %>">a s d</text>

    <text text-anchor="middle" x="270" y="280" font-size="10" style="fill:white">fireball</text>
    <text text-anchor="middle" x="300" y="280" font-size="10" style="fill:white">up</text>
    <text text-anchor="middle" x="300" y="300" font-size="30" style="fill:<%= color_2 %>">u i o</text>
    <text text-anchor="middle" x="270" y="330" font-size="10" style="fill:white">left</text>
    <text text-anchor="middle" x="300" y="330" font-size="10" style="fill:white">down</text>
    <text text-anchor="middle" x="330" y="330" font-size="10" style="fill:white">right</text>
    <text text-anchor="middle" x="300" y="350" font-size="30" style="fill:<%= color_2 %>">j k l</text>
    """
  end

  defp render_score(assigns, index) do
    field_size = @field_size
    snake_map = assigns.game_state.snake_map
    {curr_snake, snake_color} = if index == 0 do
      {snake_map.snake_1.snake, "rgb(80,200,120)"}
    else
      {snake_map.snake_2.snake, "rgb(80,120,200)"}
    end
    ~L"""
    <rect width="100" height="400" style="fill:black;stroke-width:3;stroke:<%= snake_color %>"/>
    <text text-anchor="middle" x="50" y="30" font-size="20" font-weight="bold" style="fill:<%= snake_color %>"><%= curr_snake.name %></text>
    <text text-anchor="middle" x="50" y="60" font-size="20" style="fill:<%= snake_color %>">score:</text>
    <text text-anchor="middle" x="50" y="90" font-size="20" style="fill:white"><%= curr_snake.score %></text>
    <text text-anchor="middle" x="50" y="120" font-size="20" style="fill:<%= snake_color %>">fireballs:</text>
    <text text-anchor="middle" x="50" y="150" font-size="20" style="fill:white"><%= curr_snake.fire %></text>

    <%= for fireball <- 0..curr_snake.fire do %>
      <%= if fireball != 0, do: render_fireball_at(assigns, rem(fireball-1, 3)*field_size+30, 180+div(fireball-1, 3)*field_size, 20) %>
    <% end %>
    """
  end

  defp render_board(assigns) do
    field_size = @field_size
    ~L"""
    <defs>
      <linearGradient id="Gradient2" x1="2" x2="0" y1="" y2="1">
        <stop offset="0%" stop-color="#241300"/>
        <stop offset="50%" stop-color="#625522"/>
        <stop offset="100%" stop-color="#241300"/>
      </linearGradient>
      <linearGradient id="Gradient3" x1="0" x2="1" y1="1" y2="">
        <stop offset="0%" stop-color="#241300" stop-opacity="20%"/>
        <stop offset="50%" stop-color="#625522" stop-opacity="20%"/>
        <stop offset="100%" stop-color="#241300" stop-opacity="20%"/>
      </linearGradient>
      <linearGradient id="BoardStroke" x1="0" x2="1" y1="0" y2="0">
        <stop offset="0%" stop-color="rgb(80,200,120)"/>
        <stop offset="50%" stop-color="rgb(80,120,200)"/>
      </linearGradient>
    </defs>
    <rect width="<%= assigns.game_state.board.width * field_size %>" height="<%= assigns.game_state.board.height * field_size %>" fill="url(#Gradient2)" style="stroke-width:3;stroke:url(#BoardStroke)"/>
    <rect width="<%= assigns.game_state.board.width * field_size %>" height="<%= assigns.game_state.board.height * field_size %>" fill="green" opacity="20%" style="stroke-width:3;stroke:url(#BoardStroke)"/>
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
          <%= if snake_data.snake.name == "snake-1" do %>
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

  defp render_fireball_at(assigns, x, y, r) do
    ~L"""
    <circle r="<%= r/2 %>"
        cx="<%= x %>" cy="<%= y %>"
        style="fill:DodgerBlue;stroke-width:2;stroke:rgb(50, 93, 129)"/>
    <circle r="<%= r/3 %>"
        cx="<%= x %>" cy="<%= y %>"
        style="fill:SteelBlue;stroke-width:2;stroke:SteelBlue"/>
    <circle r="<%= r/5 %>"
        cx="<%= x %>" cy="<%= y %>"
        style="fill:White;stroke-width:2;stroke:SkyBlue"/>
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

  def handle_event("keystroke", %{"key" => "u"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_1 = snake_map.snake_1
    snake_1 = %{snake_1 | fire: true}
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

  def handle_event("keystroke", %{"key" => "q"}, socket) do
    game_state = socket.assigns.game_state
    snake_map = socket.assigns.game_state.snake_map
    snake_2 = snake_map.snake_2
    snake_2 = %{snake_2 | fire: true}
    snake_map = %{snake_map | snake_2: snake_2}
    game_state = %{game_state | snake_map: snake_map}

    {:noreply, socket |> assign(:game_state, game_state)}
  end
end
