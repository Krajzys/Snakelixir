defmodule Logic.GameLoop do

  require Logger
  alias Model.Board, as: Board
  alias Model.Point, as: Point
  alias Model.Snake, as: Snake

  # ARBITRARY CONSTANT VALUES TO FEED INTO THE GAME-LOOP
  @snake_speed 1
  @dash_speed 3
  @fireball_speed 2


  # """

  # init_game(params)
  # |> game loop

  # """

  def init_game(board_width \\ 20, board_height \\ 20, player_1_name \\ "p1", player_2_name \\ "p2") do
    player_1_id = 1

    player_2_id = 2

    occupied_coordinates = []

    # TODO: TWORZENIE SNAKOW W JAKIMS ITERATORZE JAKIS FOR COS?
    snake_1 = Snake.new_random(board_width, board_height, occupied_coordinates, player_1_name, player_1_id)
    occupied_coordinates = occupied_coordinates ++ snake_1.points

    snake_2 = Snake.new_random(board_width, board_height, occupied_coordinates, player_2_name, player_2_id)
    occupied_coordinates = occupied_coordinates ++ snake_2.points

    # MOZE DAC KILKA JEDZONEK?
    food = Point.new_apple(board_width, board_height, occupied_coordinates)
    occupied_coordinates = occupied_coordinates ++ [food.coordinates]

    Board.new(width: board_width, height: board_height, snakes: [snake_1, snake_2], apples: [food], points_taken: occupied_coordinates)
  end


  """
  Czy ten wzorzec jakos sie da uzyc?
  double lastTime = getCurrentTime();
  while (true)
  {
    double current = getCurrentTime();
    double elapsed = current - lastTime;
    processInput();
    update(elapsed);
    render();
    lastTime = current;
  }
  """

  def game_loop(socket) do
    snakes_list = socket.assigns.board.snakes
    board = socket.assigns.board
    [food] = socket.assigns.board.apples
    # TODO: TIMOUT WAIT UNTIL THE PLAYERS BOTH CONFIRM THEY'RE READY
    # TODO: PROCESS CONFIGURATION INPUT
    # TODO: TUTAJ DODAC OBSLUGE INPUTU ZEBY KIERUNEK WEZA NIE ZMINEIAL SIE CO CHWILE

    # MOVE SNAKES
    moved_snakes = Enum.map(snakes_list, fn snake -> snake |> Snake.move_direction end)

    # MOVE FIREBALLS
    fireball_list = []
    fireball_list = Enum.map(fireball_list, fn(fireball) -> fireball.direction.(fireball) end)

    moved_snakes_after_check = []
    snakes_statuses = Enum.map(moved_snakes, fn snake ->
      other_snake = Snake.new()
      case Enum.filter(moved_snakes, fn snake_1 -> snake_1 != snake end) do
        [some_snake] ->
          other_snake = some_snake
        _ ->
          other_snake
      end

      other_snake_points = other_snake.points

      {snake_status, snake} = Snake.check_collision(snake, board.width, board.height, other_snake_points, food)
      game_status =
        case snake_status do
          :snake_dead ->
            IO.puts(snake.name <> " is dead!")
            # TODO: CO DALEJ?
            {:game_stop, snake}
          :snake_alive ->
            IO.puts(snake.name <> " wololo")
            # TODO: CZY ZADZIALA ZMIENNA snake_name ??
            # updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| snake: moved_snake})
            {:game_ok, snake}
          :snake_eat ->
            IO.puts(snake.name <> " ate apple")
            {:game_food, snake}  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
        end
    end)

    alive_snakes = Enum.filter(snakes_statuses, fn {status, _} -> status != :game_stop end)
    alive_snakes = Enum.map(alive_snakes, fn {status, snake} ->
      case status do
        :game_food ->
          %Model.Snake{snake | food: true}
        :game_ok ->
          %Model.Snake{snake | food: false}
        _ ->
          %Model.Snake{snake | food: false}
      end
    end)

    IO.puts(inspect alive_snakes)
    alive_snakes

    # CHECK FIREBALL COLLISIONS
    # apple_point = Point.new()
    # fireball_list = Enum.map(fireball_list, fn(fireball) ->
    #                   fireball.check_fireball_collision(fireball, board.width, board.height, snake.points, apple_point, Enum.map(List.delete(fireball_list, fireball), fn(fireball) -> fireball.coordinates end)) end)
    # usuwanie fireball z listy

    # case snakes_statuses do

    #   :game_stop ->
    #     # todo:
    #     0
    #   :game_food ->
    #     # give food new location
    #     0
    #   :game_ok ->
    #     # stuff
    #     0
    #   _ ->
    #     0
    # end

    # IF SNAKES ARE NOT DEAD THEN TRY TO SHOOT

    # """
    # {fire_status, object_colision_point, fireball, other_fireball_points_collision} =
    #   case shooting_button_1 do
    #     down ->
    #       snake1.fire(snake_1, board_width, board_height, snake_2.points, food.coordinates, Enum.map(snake_1_fireball_list, fn(fireball) -> fireball.coordinates end) )
    #     up ->
    #       _ -> nil
    #   end

    # case fire_status do
    #   :ok ->

    #   :snake_hit ->

    #   :no_ok ->

    #   :apple_destroyed ->


    # end

    #   snake_1_fireball_list = snake_1_fireball_list ++ snake_1_fireball


    # {:apple_destroyed, apple_point, fireball, fireball_points_expired}

    #             {:ok, nil, fireball, fireball_points_expired}

    #         {:snake_hit, hd(hit_point_status), fireball, fireball_points_expired}

    #     {:no_ok, fireball}

    # Enum.map(snake_1_fireball_list, fn(snake_1_fireball) -> snake_1_fireball.check_fireball_collision(snake_1_fireball, board_width, board_height, snake_1.points ++ snake_2.points, apple_point) end)



    # """



    # TODO: CZY JA MOGE DOSTAC SIE DO GAME_STATUS POZA JEGO SCOPEM??
    # JESLI TAK TO GAME STATUS if :game stop koniec rundy else gra dalej
    # JESZCZE WARUNEK NA CZAS! JAKIS TIMEOUT TEZ MOZE DAC :game_stop


  end


end



# TODO: DODAC DEFP ZAMIAST DEF JAKO PRYWATNE? W NIEKTORYCH MIEJSCACH
# TODO: STRINGI ZASTAPIC ATOMAMI!
