defmodule Model.Point do
  defstruct [
    color: :red,
    coordinates: {0, 0}
  ]

  def new(options \\ []) do
    __struct__(options)
  end

  def new_random(board_width, board_height, points_taken) do
    %__MODULE__{ # HM? czy module dziala
      color: random_color(),
      coordinates: random_coordinates(board_width, board_height, points_taken)
    }
  end

  def new_apple(id, board_width, board_height, points_taken) do
    %{
      id: id,
      color: :red, # ADD SPECIFIC COLOR
      coordinates: random_coordinates(board_width, board_height, points_taken)
    }
  end

  def new_fireball(id \\ 0, coordinates, direction_function, snake_id) do
    %{
      id: id,
      color: :yellow,
      coordinates: coordinates,
      direction: direction_function,
      snake_id: snake_id
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

  def check_fireball_collision(fireball, board_width, board_height, snakes, apples, other_fireballs) do
    fireball_coordinates = fireball.coordinates
    {fx, fy} = fireball_coordinates

    # OUT OF BOUNDS CHECK
    case fx >= 0 && fx <= board_width && fy >= 0 && fy <= board_height do
      true ->
        # FOR EACH SNAKE TRY TO FIND A COLLISION POINT
        snake_collided = Enum.find_value(snakes, {nil, nil}, fn(snake) ->
          collision_point = Enum.find(snake.points, nil, fn(snake_point) -> snake_point.coordinates == fireball_coordinates end)
          if collision_point != nil, do: {snake, %{collision_point| color: :snake_hit}} # TODO: COLOR
        end)

        # FIND OTHER FIREBALLS THAT COLLIDE WITH OURS
        other_fireballs_collided = Enum.find_value(other_fireballs, fn(other_fireball) -> if other_fireball.coordinates == fireball_coordinates, do: true end)

        apple_collided = Enum.find_value(apples, nil, fn(apple) ->
          if apple.coordinates == fireball_coordinates, do: %{apple| color: :apple_hit} # TODO: handle this
        end)

        {fireball, status} =
          cond do
            snake_collided != {nil, nil} ->
              {%{fireball| color: :snake_hit}, :fireball_snake_end}
            apple_collided != nil ->
              {%{fireball| color: :apple_hit}, :fireball_apple_end}
            other_fireballs_collided != [] ->
              {%{fireball| color: :fireball_hit}, :fireball_end}
            true ->
              {fireball, :fireball_ok}
          end
        {
          %{
          fireball: fireball,
          snake_collided: snake_collided,
          other_fireballs_collided: other_fireballs_collided,  # TODO: CZY TO WGL PRZEKAZYWAC WARTO?
          apple_collided: apple_collided
          },
          status
        }
      false ->
        {%{fireball: fireball}, :fireball_bounds_end}
    end


  end




end
