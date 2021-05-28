defmodule Logic.GameLoop do

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

  def init_game(board_wdith \\ 20, board_height \\ 20, player_1_name \\ "p1", player_2_name \\ "p2") do
    board_width = board_wdith
    board_height = board_height

    player_1_name = player_1_name
    player_1_id = 1

    player_2_name = player_2_name
    player_2_id = 2

    board = Board.new() # FIXME:
    occupied_coordinates = []

    # TODO: TWORZENIE SNAKOW W JAKIMS ITERATORZE JAKIS FOR COS?
    snake_1 = Snake.new_random(board_width, board_height, occupied_coordinates, player_1_name, player_1_id)
    occupied_coordinates = occupied_coordinates ++ snake_1.points

    snake_2 = Snake.new_random(board_width, board_height, occupied_coordinates, player_2_name, player_2_id)
    occupied_coordinates = occupied_coordinates ++ snake_2.points

    # MOZE DAC KILKA JEDZONEK?
    food = Point.new_apple(board_width, board_height, occupied_coordinates)
    occupied_coordinates = occupied_coordinates ++ [food.coordinates]

    # CO Z UZYWANIEM => W MAPACH? LINTERN DAJE OSTRZEZENIA
    %{
      snake_map: %{snake_1: %{
                                  snake: snake_1,
                                  new_direction: nil},
                  snake_2: %{
                                  snake: snake_2,
                                  new_direction: nil}},
      board: board,
      food: food,
      occupied_coordinates: occupied_coordinates
    }
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

  def game_loop(%{
    snake_map: %{snake_1: %{snake: snake_1, new_direction: nil}, snake_2: %{snake: snake_2, new_direction: nil}},
    board: board,
    food: food,
    occupied_coordinates: occupied_coordinates}) do

    # TODO: TIMOUT WAIT UNTIL THE PLAYERS BOTH CONFIRM THEY'RE READY


    # TODO: PROCESS CONFIGURATION INPUT
    # TODO: TUTAJ DODAC OBSLUGE INPUTU ZEBY KIERUNEK WEZA NIE ZMINEIAL SIE CO CHWILE


    # updated_snake_map = snake_map

    # MOVE SNAKES
    Enum.each(snake_map, fn({snake_name, snake_data}) ->
      current_snake = snake_data["snake"]
      new_direction = snake_data["new_direction"]

      snake_new_dir = Snake.change_direction(current_snake, new_direction)
      moved_snake = Snake.move_direction(snake_new_dir)

      updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| snake: moved_snake}) # tutaj snake_moved? bylo moved
    end)

    snake_map = updated_snake_map

    # MOVE FIREBALLS
    fireball_list = Enum.map(fireball_list, fn(fireball) -> fireball.direction.(fireball) end)

    """
    color: :yellow,
      coordinates: coordinates,
      direction: direction_function,
      snake_id: id
    """
    # STANY KTO GDZIE WPADL?
    # CHECK SNAKE COLLISIONS
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
            updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| snake: moved_snake})
            :game_ok
          :snake_eat ->
            updated_snake_map = Map.put(updated_snake_map, snake_name, %{updated_snake_map[snake_name]| snake: moved_snake})
            :game_food  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
        end
    end)

    # CHECK FIREBALL COLLISIONS
    fireball_list = Enum.map(fireball_list, fn(fireball) ->
                      fireball.check_fireball_collision(fireball, board_width, board_height, snake_points, apple_point, Enum.map(List.delete(fireball_list, fireball), fn(fireball) -> fireball.coordinates end)) end)
    # usuwanie fireball z listy

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
