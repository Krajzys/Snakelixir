defmodule Model.Snake do

  alias Model.Point, as: Point

  defstruct [
    name: "player -",
    score: 0,
    points: [],
    apples: 0,
    direction: "right", # TUTAJ LOSOWANIE, BAZUJĄCE NA POŁOŻENIU WZGLĘDEM KRAWĘDZI
    food: False,
    fire: False,
    dash: False
  ]

  # TODO: REPLACE STRINGS FOR DIRECTIONS WITH ATOMS?

  def new(options \\ []) do
    __struct__(options)
  end


  def new_random(_board_width, _board_height, _taken_points, player_name) do
    starting_point = Point.new_random(_board_width, _board_height, _taken_points)
    %__MODULE__{ # TODO: CHECKOUT HM? czy module dziala
      name: player_name,
      score: 0,
      points: [starting_point],
      apples: 0,
      direction: start_direction(_board_width, _board_height, starting_point),
      food: False,
      fire: False,
      dash: False
    }
  end

  # We don't wanna spawn and immediately have our snake smashed againts the wall, now do we?
  # Could be resolved by the snake remaining stationary until first direction is chosen
  def safety_margin(value) do
    case value do
      1 -> 0
      x when x in 2..5 -> 1
      x when x in 6..10 -> 2
      x when x in 11..15 -> 4
      _ -> 5
    end
  end


  def start_direction(board_width, board_height, starting_position) do
    # TODO: CHECK IF POSITION WITHIN BOARD DIMS? HM IT HAS TO BE
    # TODO: GET AVAILABLE POSITIONS BECAUSE OF THE OTHER SNAKE???

    available_directions = ["left", "right", "down", "up"]
    {x, y} = starting_position

    width_index = board_width-1
    height_index = board_height-1

    start_width_safety_margin = safety_margin(board_width)
    start_height_safety_margin = safety_margin(board_height)

    end_width_safety_margin = width_index - start_width_safety_margin
    end_height_safety_margin = height_index - start_height_safety_margin

    # TODO: DODAC RAZEM WYKLUCZAJACE SIE KIERUNKI
    available_directions = case {x, y} do
      {horizontal_wall, _} when horizontal_wall in 0..start_width_safety_margin -> available_directions -- ["left"]
      _ -> available_directions
    end
    # IO.puts(["available dirs == ", Enum.join(available_directions, " ")]) # DEBUG
    available_directions = case {x, y} do
      {_, vertical_wall} when vertical_wall in 0..start_height_safety_margin -> available_directions -- ["up"]
      _ -> available_directions
    end
    # IO.puts(["available dirs == ", Enum.join(available_directions, " ")]) # DEBUG
    available_directions = case {x, y} do
      {horizontal_wall, _} when horizontal_wall in width_index..end_width_safety_margin -> available_directions -- ["right"]
      _ -> available_directions
    end
    # IO.puts(["available dirs == ", Enum.join(available_directions, " ")]) # DEBUG
    available_directions = case {x, y} do
      {_, vertical_wall} when vertical_wall in height_index..end_height_safety_margin -> available_directions -- ["down"]
      _ -> available_directions
    end
    # IO.puts(["available dirs == ", Enum.join(available_directions, " ")]) # DEBUG
    random_direction(available_directions)
  end

  def random_direction(possible_directions) do
    possible_directions
    |> Enum.shuffle()
    |> List.first
  end

  # TODO: on keypress
  # TODO: szybka zmiana kierunku -> handler/blokada
  def change_direction(snake, new_direction) do
    old_direction = snake.direction
    case new_direction do
      ^old_direction ->
        snake
      "left" when old_direction == "right" ->
        snake
      "right" when old_direction == "left" ->
        snake
      "up" when old_direction == "down" ->
        snake
      "down" when old_direction == "up" ->
        snake
        _ -> %{snake| direction: new_direction}
    end
  end


  def move_direction(snake) do
    # COND ZWROCI WYNIK MOVE_DIR CZYLI WEZA Z ZAKTUALIZWOANYMI DANYMI
    cond do
      snake.direction == "left" ->
        move_left(snake)
      snake.direction == "right" ->
        move_right(snake)
      snake.direction == "up" ->
        move_up(snake)
      snake.direction == "down" ->
        move_down(snake)
    end
  end

  def move(snake) do
    head = hd(snake.points)
    case snake.food do
      True ->
        %{snake| food: False}
      False ->
        removed_tail = snake.points |> Enum.reverse() |> tl() |> Enum.reverse()
        %{snake| points: [head | removed_tail]}
    end
  end

  def move_down(snake) do
    snake = move(snake)
    head = hd(snake.points)
    tail = tl(snake.points)
    %{snake| points: [Point.move_down(head) | tail]}
  end

  def move_up(snake) do
    snake = move(snake)
    head = hd(snake.points)
    tail = tl(snake.points)
    %{snake| points: [Point.move_up(head) | tail]}
  end

  def move_left(snake) do
    snake = move(snake)
    head = hd(snake.points)
    tail = tl(snake.points)
    %{snake| points: [Point.move_left(head) | tail]}
  end

  def move_right(snake) do
    snake = move(snake)
    head = hd(snake.points)
    tail = tl(snake.points)
    %{snake| points: [Point.move_right(head) | tail]}
  end

  # TODO: LISTA SNAKOW CZY RACZEJ DWA ARGUMETY
  # TODO: MUSI BYC WYKONAA FUNKCJA PO move_direction
  # NIE JEST WYWOŁANA BEZPOŚREDNIO Z MOVE)DIRECTION BO NIE MA ONA WIEDZY O STANIE 2 SNAKE'a
  def check_collision(moved_snake, board_width, board_height, other_snake_points, apple_point) do

    [head | tail] = moved_snake
    {hx, hy} = head.coordinates

    # MARK IF SHOULD EAT, INC SCORE
    moved_snake =
      case apple_point.coordinates do
        {hx, hy} ->
          new_score =
            case moved_snake.score do
              0 ->
                100
              1 -> 200
              _ -> Integer.pow(moved_snake.score, moved_snake.apples)
            end
          %{moved_snake| score: new_score, apples: moved_snake.apples + 1, food: True}
        _ ->
          moved_snake
      end

    # WALL COLLISION
    wall_collision_check = hx > 0 && hx < board_width && hy > 0 && hy < board_height

    case wall_collision_check do
        false ->
          {:snake_dead, moved_snake}
        true ->
          # SNAKE COLLISION
          snake_collision_check = Enum.any?(other_snake_points, fn(other_snake_point) -> head == other_snake_point end)
          case snake_collision_check do
            true ->
              {:snake_dead, moved_snake}
            false ->
              case moved_snake.food do
                True ->
                  {:snake_eat, moved_snake}
                False ->
                  {:snake_alive, moved_snake}
              end
          end
    end
  end

  # TODO: IDEA -> would be cool to implement because PvP
  # Timebar based dash that regenerates once every N seconds and makes the snake traverse a couple blocks in one quantum of time.
  def dash(snake) do


  end

  # TODO: IDEA -> same as dash
  # Once the snake eats a given N number of apples it can spit out a fireball (the bigger you are the more you fireballs you get?):
  #   if the fireball hits the opponent, its blocks are removed from the hit-block down.
  #   headshots are insta-kill
  #   would have to tinker with the ball's speed to get it right
  # It boils down to creating a new point with custom graphics that is moved a certain direction, doesnt even have to be a module,
  # the direction could be taken from the snake and memorized in the game loop
  def fire() do

  end

end
