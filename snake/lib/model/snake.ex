defmodule Snake.Snake do
  defstruct [
    name: "player -",
    score: 0,
    points: [],
    apples: 0,
    direction: "right" # TUTUAJ LOSOWANIE, BAZUJĄCE NA POŁOŻENIU WZGLĘDEM KRAWĘDZI
  ]


  def new() do
    __struct__()
  end


  def new_random(_board_width, _board_height, player_name) do
    starting_point = Snake.Point.new_random(_board_width, _board_height)
    %__MODULE__{ # HM? czy module dziala
      name: player_name,
      score: 0,
      points: [starting_point],
      apples: 0,
      direction: start_direction(_board_width, _board_height, starting_point)
    }
  end

  # We dont wanna spawn and immediately have our snake smashed againts the wall, now do we?
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
    # TODO: CHECK IF POSITION WITHIN BOARD DIMS?

    # TODO: GET AVAILABLE POSITIONS BECAUSE OF THE OTHER SNAKE???

    available_directions = ["left", "right", "down", "up"]
    {x, y} = starting_position

    width_index = board_width-1
    height_index = board_height-1

    start_width_safety_margin = safety_margin(board_width)
    start_height_safety_margin = safety_margin(board_height)

    end_width_safety_margin = width_index - start_width_safety_margin
    end_height_safety_margin = height_index - start_height_safety_margin

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
  def change_direction(snake, new_direction) do
    case new_direction do
      snake.direction ->
        snake
      "left" when snake.direction == "right" ->
        snake
      "right" when snake.direction == "left" ->
        snake
      "up" when snake.direction == "down" ->
        snake
      "down" when snake.direction == "up" ->
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
    # TODO: ADD COLLISION CHECKS!
  end

  def move(snake) do
    # TODO: SKROCENIE INNYCH MOVE?
  end

  def move_down(snake) do
    head = hd(snake.points)
    removed_tail = snake.points |> Enum.reverse() |> tl() |> Enum.reverse()
    %{snake| points: [Snake.Point.move_down(head) | removed_tail]}
  end

  def move_up(snake) do
    head = hd(snake.points)
    removed_tail = snake.points |> Enum.reverse() |> tl() |> Enum.reverse()
    %{snake| points: [Snake.Point.move_up(head) | removed_tail]}
  end

  def move_left(snake) do
    head = hd(snake.points)
    removed_tail = snake.points |> Enum.reverse() |> tl() |> Enum.reverse()
    %{snake| points: [Snake.Point.move_left(head) | removed_tail]}
  end

  def move_right(snake) do
    head = hd(snake.points)
    removed_tail = snake.points |> Enum.reverse() |> tl() |> Enum.reverse()
    %{snake| points: [Snake.Point.move_right(head) | removed_tail]}
  end

  def eat(snake) do
    # TODO:
  end

  # LISTA SNAKOW CZY RACZEJ DWA ARGUMETY
  def check_collision(snake_list, board) do
    # TODO: CHECK POINTS THAT ARE TAKEN AND IF OUT OF MAP
    # PASS TEH HOLE BOARD OBJ OR JUST DIMENSIONS AS A TUPLE?
  end

end
