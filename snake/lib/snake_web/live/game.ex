defmodule SnakeWeb.Live.Game do
  @moduledoc """
  Main module, contains the entry point for the live view socket and
  all the game logic
  """

  use Phoenix.LiveView

  alias Phoenix.LiveView.Socket
  alias SnakeWeb.Live.Blocks

  # Time in ms that schedules the game loop
  @tick 16
  # Width in pixels, used as the base for every type of block: bricks, paddle, walls, etc.
  # Every length param is expressed as an integer multiple of the basic unit
  @unit 20

  @board_rows 21
  @board_cols 26

  @level [
    ~w(X X X X X X X X X X X X X X X X X X X X X X X X X X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X r 0 0 r 0 0 r 0 0 r 0 0 r 0 0 r 0 0 r 0 0 r 0 0 X),
    ~w(X b 0 0 b 0 0 b 0 0 b 0 0 b 0 0 b 0 0 b 0 0 b 0 0 X),
    ~w(X g 0 0 g 0 0 g 0 0 g 0 0 g 0 0 g 0 0 g 0 0 g 0 0 X),
    ~w(X o 0 0 o 0 0 o 0 0 o 0 0 o 0 0 o 0 0 o 0 0 o 0 0 X),
    ~w(X p 0 0 p 0 0 p 0 0 p 0 0 p 0 0 p 0 0 p 0 0 p 0 0 X),
    ~w(X y 0 0 y 0 0 y 0 0 y 0 0 y 0 0 y 0 0 y 0 0 y 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(X 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 X),
    ~w(D D D D D D D D D D D D D D D D D D D D D D D D D D)
  ]

  def render(assigns) do
    SnakeWeb.GameView.render("index.html", assigns)
  end

  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_param, _session, socket) do
    state = %{unit: @unit, tick: @tick}

    socket =
      socket
      |> assign(state)
      |> assign(:blocks, Blocks.build_board(@level, state.unit, state.unit))

    if connected?(socket) do
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  @spec schedule_tick(Socket.t()) :: Socket.t()
  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, socket.assigns.tick)
    socket
  end

  @spec handle_info(atom(), Socket.t()) :: {:noreply, Socket.t()} | {:stop, Socket.t()}
  def handle_info(:tick, socket) do
    new_socket =
      socket
      |> game_loop()
      |> schedule_tick()

    {:noreply, new_socket}
  end

  @spec game_loop(Socket.t()) :: Socket.t()
  defp game_loop(socket) do
    IO.puts("noop!")

    socket
  end
end
