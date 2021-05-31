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
      assign(socket, %{board: Logic.GameLoop.init_game(20, 20, "snake-1", "snake-2"), fireballs: [Point.new_fireball({5,5}, nil, 1)]})
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
    </defs>
    <rect width="<%= assigns.board.width * field_size %>" height="<%= assigns.board.height * field_size %>" fill="url(#Gradient2)"/>
    <rect width="<%= assigns.board.width * field_size %>" height="<%= assigns.board.height * field_size %>" fill="green" opacity="20%"/>
    """
  end

  defp render_snake(assigns) do
    field_size = @field_size

    ~L"""
    <%= for snake <- assigns.board.snakes do %>
      <%= for {point, no} <- Enum.zip(snake.points, 0..(length(snake.points)-1)) do %>
        <% {x, y} = point.coordinates %>
        <% r_color_number = if rem(div(no*40, 200), 2) == 1, do: rem(no*40, 200), else: 200-rem(no*40, 200) %>
        <% magic_number = if rem(div(no*2, 4), 2) == 1, do: rem(no*2, 4), else: 4-rem(no*2, 4) %>
        <% magic_number = abs(magic_number - 4) %>
          <rect width="<%= field_size - magic_number %>" height="<%= field_size - magic_number %>"
          x="<%= x * field_size + magic_number/2 %>" y="<%= y * field_size + magic_number/2 %>"
          style="fill:
          <%= if snake.name == "snake-1" do %>
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
    <%= for apple <- assigns.board.apples do %>
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
    <%= for fireball <- assigns.fireballs do %>
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
