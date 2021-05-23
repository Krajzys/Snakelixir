defmodule Logic.GameLoop do

  alias Model.Board, as: Board
  alias Model.Point, as: Point
  alias Model.Snake, as: Snake

  def game_loop() do

    # TODO: PROCESS CONFIGURATION INPUT
    # TODO: TUTAJ DODAC OBSLUGE INPUTU ZEBY KIERUNEK WERZA NIE ZMINEIAL SIE CO CHWILE

    # INITIALIZATION

    board_width = 20 # TODO: GET FROOM INPUT
    board_height = 20 # TODO: PASS TO BOARD

    player_1_name = ""
    player_2_name = ""

    board = Board.new() # FIXME:
    taken_points = []

    # TODO: TWORZENIE SNAKOW W JAKIMS ITERATORZE JAKIS FOR COS?
    snake_1 = Snake.new_random(board_width, board_height, taken_points, player_1_name)
    taken_points = taken_points ++ snake_1.points

    snake_2 = Snake.new_random(board_width, board_height, taken_points, player_2_name)
    taken_points = taken_points ++ snake_2.points
    # MOZE DAC KILKA JEDZONEK?
    food = Point.new_apple(board_width, board_height, taken_points)
    taken_points = taken_points ++ [food.coordinates]

    # TODO: TIMOUT WAIT UNTIL THE PLAYERS BOTH CONFIRM THEY'RE READY

    snake_map = %{"snake_1" => %{"snake": snake_1, "new_direction": nil}, "snake_2" => %{"snake": snake_2, "new_direction": nil}}
    updated_snake_map = snake_map

    Enum.each(snake_map, fn({snake_name, snake_data}) ->
      current_snake = snake_data["snake"]
      new_direction = snake_data["new_direction"]

      snake_new_dir = Snake.change_direction(current_snake, new_direction)
      moved_snake = Snake.move_direction(snake_new_dir)

      updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| "snake": moved_snake}) # tutaj snake_moved? bylo moved
    end)

    snake_map = updated_snake_map

    # STANY KTO GDZIE WPADL?
    snakes_statuses = Enum.map(snake_map, fn({snake_name, snake_data}) ->
      other_snake = List.delete(Map.keys(snake_map), snake_name) # ZROBIONE DLA 2 snakow;

      moved_snake = snake_data["snake"]

      other_snake_points = updated_snake_map[other_snake]["snake"].points

      {snake_status, snake} = Snake.check_collision(moved_snake, board_width, board_height, other_snake_points, food.coordinates)
      game_status =
        case snake_status do
          :snake_dead ->
            IO.puts(snake_name + " is dead!")
            # TODO: CO DALEJ?
            :game_stop
          :snake_alive ->
            # TODO: CZY ZADZIALA ZMIENNA snake_name ??
            updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| "snake": moved_snake})
            :game_ok
          :snake_eat ->
            updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| "snake": moved_snake})
            :game_food  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
        end
    end)


    case snakes_statuses do

      :game_stop ->
        # todo:
        0
      :game_food ->
        # give food new location
        0
      :game_ok ->
        # stuff
        0
      _ ->
        0
    end

    # TODO: CZY JA MOGE DOSTAC SIE DO GAME_STATUS POZA JEGO SCOPEM??
    # JESLI TAK TO GAME STATUS if :game stop koniec rundy else gra dalej
    # JESZCZE WARUNEK NA CZAS! JAKIS TIMEOUT TEZ MOZE DAC :game_stop


  end


end



# TODO: DODAC DEFP ZAMIAST DEF JAKO PRYWATNE? W NIEKTORYCH MIEJSCACH
# TODO: STRINGI ZASTAPIC ATOMAMI!
