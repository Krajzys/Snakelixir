defmodule Snake.Point do
  defstruct [
    color: "red",
    coordinates: {0, 0}
  ]

  def new() do
    __struct__()
  end

  def new_random(_board_height, _board_width) do
    %__MODULE__{ # HM? czy module dziala
      color: random_color(),
      coordinates: random_coordinates(_board_height, _board_width)
    }
  end

  # TODO:
  def new_apple() do
    %{ # HM? czy module dziala
    color: random_color(),
    coordinates: random_coordinates(_board_height, _board_width)
  }
  end


  def random_color() do
    ["blue", "red", "green", "yellow"]
    |> Enum.shuffle()
    |> List.first
  end

  def random_coordinates(board_height, board_width) do
    # range 0..n
    board_height = board_height - 1
    board_width = board_width - 1
    {Enum.random(0..board_width), Enum.random(0..board_height)}
  end

  def move_down(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x, y-1}}
  end

  def move_up(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x, y+1}}
  end

  def move_left(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x-1, y}}
  end

  def move_left(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x+1, y}}
    end

end
