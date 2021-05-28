defmodule Model.Point do
  defstruct [
    color: "red",
    coordinates: {0, 0}
  ]

  def new(options \\ []) do
    __struct__(options)
  end

  def new_random(_board_width, _board_height, _points_taken) do
    %__MODULE__{ # HM? czy module dziala
      color: random_color(),
      coordinates: random_coordinates(_board_width, _board_height, _points_taken)
    }
  end

  def new_apple(_board_width, _board_height, _points_taken) do
    %{
    color: "red", # ADD SPECIFIC COLOR
    coordinates: random_coordinates(_board_width, _board_height, _points_taken)
  }
  end


  defp random_color() do
    ["blue", "red", "green", "yellow"]
    |> Enum.shuffle()
    |> List.first
  end

  defp random_coordinates(board_height, board_width, points_taken) do
    # range 0..n
    board_height = board_height - 1
    board_width = board_width - 1

    available_points =
      Enum.map(0..board_width, fn(i) -> Enum.map(0..board_height, fn(j) -> {i, j} end) end)
      |> List.flatten()
      |> Enum.filter(fn(point) -> !Enum.any?(points_taken, fn(taken_point) -> taken_point == point end) end)
    Enum.random(available_points)
  end

  def move_down(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x, y+1}}
  end

  def move_up(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x, y-1}}
  end

  def move_left(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x-1, y}}
  end

  def move_right(point) do
    {x, y} = point.coordinates
    %{point| coordinates: {x+1, y}}
  end

end
