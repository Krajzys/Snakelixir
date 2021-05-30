defmodule Model.Point do
  defstruct [
    color: :red,
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
    color: :red, # ADD SPECIFIC COLOR
    coordinates: random_coordinates(_board_width, _board_height, _points_taken)
    }
  end

  def new_fireball(coordinates, direction_function, id) do
    %{
      color: :yellow,
      coordinates: coordinates,
      direction: direction_function,
      snake_id: id
    }
  end


  defp random_color() do
    [:blue, :red, :green, :yellow]
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

  def check_fireball_collision(fireball, board_width, board_height, snake_points, apple_point, fireball_points) do
    fireball_coordinates = fireball.coordinates
    {fx, fy} = fireball_coordinates

    # CO JAK FIREBALLE MAJA KOLIZE!!!??? TO TEZ WYBUCHAJA

    border_check = fx > 0 && fx < board_width && fy > 0 && fy < board_height

    case border_check do
      true ->
        snake_hit_point = Enum.filter(snake_points, fn(snake_point) -> snake_point == fireball_coordinates end)
        hit_point_status = length(snake_hit_point)
        fireball_hit_point = Enum.filter(fireball_points, fn(fireball_point) -> fireball_point == fireball_coordinates end)
        # fireball_point_status = length(fireball_hit_point)
        # fireball_points_expired =
        #   case fireball_point_status do
        #     0 ->
        #       fireball_hit_point
        #     _ -> [fireball_coordinates | fireball_hit_point] # LIST OF ALL POINTS TO REMOVE
        #   end

        case hit_point_status do
          0 ->
            case fireball_coordinates do
              apple_point ->
                {:apple_destroyed, apple_point, fireball, fireball_hit_point}
              _ ->
                {:ok, nil, fireball, fireball_hit_point}
            end
          1 ->
            {:snake_hit, hd(hit_point_status), fireball, fireball_hit_point}
          _ ->
            IO.puts("Snake hit point Error!")
        end
      false ->
        {:no_ok, nil, fireball, nil}
    end


  end




end
