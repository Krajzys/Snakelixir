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

  def init_game(board_width \\ 20, board_height \\ 20, player_1_name \\ "p1", player_2_name \\ "p2") do
    # board_width = board_width
    # board_height = board_height

    # player_1_name = player_1_name
    player_1_id = 1

    # player_2_name = player_2_name
    player_2_id = 2

    apple_id = 0

    board = Board.new() # FIXME:
    occupied_coordinates = []

    snake_1 = Snake.new_random(board_width, board_height, occupied_coordinates, player_1_name, player_1_id)
    occupied_coordinates = occupied_coordinates ++ snake_1.points

    snake_2 = Snake.new_random(board_width, board_height, occupied_coordinates, player_2_name, player_2_id)
    occupied_coordinates = occupied_coordinates ++ snake_2.points

    apple = Point.new_apple(apple_id, board_width, board_height, occupied_coordinates)
    occupied_coordinates = occupied_coordinates ++ [apple.coordinates]

    fireball_list = []

    # CO Z UZYWANIEM => W MAPACH? LINTERN DAJE OSTRZEZENIA

    game_state =
      %{
        snake_map: %{snake_1: %{
                                    snake: snake_1,
                                    new_direction: nil},
                    snake_2: %{
                                    snake: snake_2,
                                    new_direction: nil}},
        board: board,
        apples: [apple],
        fireballs: fireball_list,
        occupied_coordinates: occupied_coordinates, # TODO: CZY TO WGL POTRZEBNE??
        next_apple_id: apple_id + 1,
        next_fireball_id: 0,
        fireball_ids_to_remove: [],
        apple_ids_to_remove: [],
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


  defp snakes_move(snake_map) do
    {_, snake_map} =
      Enum.map_reduce(snake_map, snake_map, fn({{snake_name, snake_data}, acc_map}) ->
        current_snake = snake_data.snake
        current_snake_id = current_snake.id
        new_direction = snake_data.new_direction

        snake_new_dir = Snake.change_direction(current_snake, new_direction)
        moved_snake = Snake.move_direction(snake_new_dir)

        acc_map = Map.put(acc_map, snake_name, %{updated_snake_map[snake_name]| snake: moved_snake})
        {current_snake_id, acc_map}
      end)
    snake_map
  end

  defp snakes_collision(snake_map, board, apples) do
    Enum.map(snake_map, fn({snake_name, snake_data}) ->
      other_snake = List.delete(Map.keys(snake_map), snake_name) # ZROBIONE DLA 2 snakow;

      moved_snake = snake_data["snake"]

      other_snake_points = snake_map[other_snake]["snake"].points

      {snake_status, moved_snake, eaten_apple} = Snake.check_collision(moved_snake, board.width, board.height, other_snake_points, apples)
      # TODO: OZNACZANIE JAKI SNEAK UMIERA ITP, JAKIES ID DO STATUSU ?
      game_status =
        case snake_status do
          :snake_dead ->
            # {:game_dead, moved_snake.id, snake_map, eaten_apple}
            {:game_dead, moved_snake.id, moved_snake, eaten_apple}
          :snake_alive ->
            # updated_snake_map = Map.put(snake_map, snake_name, %{snake_map[snake_name]| snake: moved_snake})
            # {:game_ok, moved_snake.id, updated_snake_map, eaten_apple}
            {:game_ok, moved_snake.id, moved_snake, eaten_apple}
          :snake_eat ->
            # updated_snake_map = Map.put(snake_map, snake_name, %{snake_map[snake_name]| snake: moved_snake})
            # {:game_food, moved_snake.id, updated_snake_map, eaten_apple}  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
            {:game_food, moved_snake.id, moved_snake, eaten_apple}  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
        end
    end)
  end

  defp fireballs_move(fireballs) do
    Enum.map(fireballs, fn(fireball) -> fireball.direction.(fireball) end)
  end

  defp fireballs_collision(fireballs, board, snakes, apples) do
    Enum.map(fireballs, fn(current_fireball) ->
      {
        Point.check_fireball_collision( # CZY KOLORY NA ZEWNATRZ ZMIENIAC
          current_fireball,
          board.width,
          board.height,
          snakes,
          apples,
          Enum.map(
            Enum.filter(fireballs, fn(filter_fireball) -> filter_fireball.id != current_fireball.id end),
            fn(fireball) -> fireball.coordinates end)
        )
      }
      end)
  end

  defp mark_fireballs(fireball_collision_checks) do
    fireball_collision_checks
      |> Enum.filter(fn({map, status}) -> status != :fireball_ok end)
      |> Enum.map(fn({map, status}) -> map.fireball.id end)
  end

  defp mark_apples(fireball_collision_checks) do
    fireball_collision_checks
    |> Enum.filter(fn({map, status}) -> status == :fireball_apple_end end)
    |> Enum.map(fn({map, status}) -> map.apple_collided.id end)
  end


  defp snakes_fireball_damage(fireball_collision_checks) do
    {_, %{snake_1: snake1, snake_2: snake2}} = # TODO: !!!!!!!!!!!!!!!!! JAK SNAKE MA DLUGOSC 0 PUNKTOW TO DEAD
      fireball_collision_checks
      |> Enum.filter(fn({map, status}) -> status == :fireball_snake_end end)
      |> Enum.map_reduce(%{snake_1: nil, snake_2: nil},  # TUTAJ MOZNABY WRZUCIC SNAKI OD RAZU
          fn({map, status}, acc_map) ->
            {snake, collision_point} = map.snake_collided
            snake_id = snake.id
            acc_map =
              case Map.get(acc_map, "snake_#{snake_id}", nil) do # TODO: CZY TO DZIALA?
                nil ->
                  Map.update(acc_map, "snake_#{snake_id}", fn(s) -> snake end)
                _ ->
                  acc_map
              end
            acc_map = Map.update(acc_map, "snake_#{snake_id}", fn(s) -> Snake.remove_blockdown(s, collision_point.coordinates) end)
            {collision_point, acc_map}
          end)
    {snake1, snake2}
  end

  # TODO: TIMOUT WAIT UNTIL THE PLAYERS BOTH CONFIRM THEY'RE READY
  def game_loop(socket) do

    # TODO: SPAWNOWANIE JABLEK!!!!!!!!! I PUNKTY ITP

    # GAME FLOW:
    # REMOVE ALL DESTROYED OBJECTS
    # MOVE THE SNAKES
    # MOVE THE FIREBALLS
    # CHECK SNAKE AND (after that) FIREBALL COLLISIONS
    # IF THE SNAKES ARE ALIVE AND ANY GIVEN ONE WANTS TO SHOOT, CREATE A FIREBALL AND CHECK COLLISIONS AGAIN

    assings = socket.assigns
    game_state = assigns.game_state
    snake_map = game_state.snake_map
    board = game_state.board
    apples = game_state.apples
    fireballs = game_state.fireballs
    occupied_coordinates = game_state.occupied_coordinates # FIXME CZY TO POTRZEBNE
    next_apple_id = game_state.next_apple_id
    next_fireball_id = game_state.next_fireball_id  # TODO: UZYC TEGO!!
    fireball_ids_to_remove = game_state.fireball_ids_to_remove
    apple_ids_to_remove = game_state.fireball_ids_to_remove

    updated_snake_map = snake_map

    # AT THE STAR OF THE ITERATION, REMOVE USED UP OBJECTS
    apples = Enum.filter(apples, fn(apple) -> !Enum.member?(apple_ids_to_remove, apple.id) end)
    fireballs = Enum.filter(fireballs, fn(fireball) -> !Enum.member?(fireball_ids_to_remove, fireball.id) end)

    # MOVE SNAKES
    snake_map = snakes_move(snake_map)

    # MOVE FIREBALLS
    moved_fireballs = fireballs_move(fireballs)

    # CHECK SNAKE COLLISIONS
    snake_statuses = snakes_collision(snake_map)

    apple_ids_to_remove = apple_ids_to_remove ++
      Enum.filter(snake_statuses, fn({status, snake_id, snake, apple}) -> status == :snake_eat end)
      |> Enum.map(fn({status, snake_id, snake, apple}) -> apple.id end)

    snake_1 = elem(Enum.filter(snake_statuses, fn({status, snake_id, snake, apple}) -> snake_id == 1 end), 1)
    snake_2 = elem(Enum.filter(snake_statuses, fn({status, snake_id, snake, apple}) -> snake_id == 2 end), 1)

    """ # TODO: PROCESS STATES
    :snake_dead ->
      # {:game_dead, moved_snake.id, snake_map, eaten_apple}
      {:game_dead, moved_snake.id, moved_snake, eaten_apple}
    :snake_alive ->
      # updated_snake_map = Map.put(snake_map, snake_name, %{snake_map[snake_name]| snake: moved_snake})
      # {:game_ok, moved_snake.id, updated_snake_map, eaten_apple}
      {:game_ok, moved_snake.id, moved_snake, eaten_apple}
    :snake_eat ->
      # updated_snake_map = Map.put(snake_map, snake_name, %{snake_map[snake_name]| snake: moved_snake})
      # {:game_food, moved_snake.id, updated_snake_map, eaten_apple}  # TODO: SYGNAL ZE JEDZENIE ZJEDZONE I MA ZNIKNAC
      {:game_food, moved_snake.id, moved_snake, eaten_apple}
    """


    # CHECK FIREBALL COLLISIONS
    fireball_collision_checks = fireballs_collision(fireballs, board, snake_1 ++ snake_2, apples)

    # MARK FIREBALLS FOR DELETION AT THE START OF A NEW ITERATION
    fireball_ids_to_remove = mark_fireballs(fireball_collision_checks)

    # MARK APPLES FOR DELETION AT THE START OF A NEW ITERATION
    apple_ids_to_remove = mark_apples(fireball_collision_checks)

    # APPLY FIREBALL DAMAGE TO SNAKES USING 'Snake.remove_blockdown' AND SHORTEN THEIR TAILS
    {snake1, snake2} = snakes_fireball_damage(fireball_collision_checks)

    snake1_dead = length(snake1.points) == 0
    snake2_dead = length(snake2.points) == 0

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


    # TODO: 1. JESLI SNAKE ZYJE I CHCE STRZELIC TO STRZEL -> STWORZ FIREBALLA I SPRAWDZ ZNOWU KOLIZJE
    # TODO: 2. CHECK SNAKE_COLLISIONS I FIREBALL

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

    %{
      snake_map: snake_map,
      board: board,
      apples: apples,
      fireballs: fireballs,
      next_apple_id: apple_id + 1,
      next_fireball_id: fireball_id + 1,
      fireball_ids_to_remove: fireball_ids_to_remove,
      apple_ids_to_remove: apple_ids_to_remove
    }
  end


end
