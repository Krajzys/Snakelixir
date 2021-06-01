defmodule Logic.GameLoop do

  alias Model.Board, as: Board
  alias Model.Point, as: Point
  alias Model.Snake, as: Snake

  # ARBITRARY CONSTANT VALUES TO FEED INTO THE GAME-LOOP
  @snake_speed 1
  @dash_speed 3
  @fireball_speed 2

  # TODO: map_reduce -> reduce

  def init_game(board_width \\ 20, board_height \\ 20, player_1_name \\ "p1", player_2_name \\ "p2") do
    # board_width = board_width
    # board_height = board_height

    # player_1_name = player_1_name
    player_1_id = 1

    # player_2_name = player_2_name
    player_2_id = 2

    apple_id = 0

    board = Board.new([width: board_width, height: board_height])
    occupied_coordinates = []

    snake_1 = Snake.new_random(board_width, board_height, occupied_coordinates, player_1_name, player_1_id)
    occupied_coordinates = occupied_coordinates ++ snake_1.points

    snake_2 = Snake.new_random(board_width, board_height, occupied_coordinates, player_2_name, player_2_id)
    occupied_coordinates = occupied_coordinates ++ snake_2.points

    apple = Point.new_apple(apple_id, board_width, board_height, occupied_coordinates)
    # occupied_coordinates = occupied_coordinates ++ [apple.coordinates]

    # FIXME UNDO 2 LINES
    # p1 = Enum.at(snake_1.points, 0)
    # p2 = Enum.at(snake_2.points, 0)
    # p1 = %{p1| coordinates: {1, 1}}
    # p2 = %{p2| coordinates: {3, 1}}
    # snake_1 = %{snake_1| points: [p1], direction: :right}
    # snake_2 = %{snake_2| points: [p2], direction: :left}

    fireball_list = []

    # game_state
    %{
      snake_map: %{
                  snake_1: %{
                                  snake: snake_1,
                                  new_direction: snake_1.direction,
                                  fire: false},
                  snake_2: %{
                                  snake: snake_2,
                                  new_direction: snake_2.direction,
                                  fire: false}},
      board: board,
      apples: [apple],
      fireballs: fireball_list,
      next_apple_id: apple_id + 1,
      next_fireball_id: 0,
      fireball_ids_to_remove: [],
      apple_ids_to_remove: [],
      iteration: 0,
      status: :game_start
    }
  end

  defp snakes_move(snake_map) do
    snake_map =
      Enum.reduce(snake_map, snake_map, fn({snake_name, snake_data}, acc_map) ->
        current_snake = snake_data.snake
        new_direction = snake_data.new_direction

        snake_new_dir = Snake.change_direction(current_snake, new_direction)
        moved_snake = Snake.move_direction(snake_new_dir)

        Map.put(acc_map, snake_name, %{Map.get(acc_map, snake_name) | snake: moved_snake})
      end)
    snake_map
  end

  defp snakes_collision(snake_map, board, apples) do
    Enum.map(snake_map, fn({snake_name, snake_data}) ->

      moved_snake = snake_data.snake

      [other_snake_name] = List.delete(Map.keys(snake_map), snake_name) # ZROBIONE DLA 2 snakow;
      other_snake = Map.get(snake_map, other_snake_name)
      other_snake_points = Enum.map(other_snake.snake.points, fn(point) -> point.coordinates end)

      {snake_status, moved_snake, eaten_apple} = Snake.check_collision(moved_snake, board.width, board.height, other_snake_points, apples)
      case snake_status do
        :snake_dead ->
          {:game_dead, moved_snake.id, moved_snake, eaten_apple}
        :snake_alive ->
          {:game_ok, moved_snake.id, moved_snake, eaten_apple}
        :snake_eat ->
          {:game_food, moved_snake.id, moved_snake, eaten_apple}
      end
    end)
  end

  defp fireballs_move(fireballs) do
    Enum.map(fireballs, fn(fireball) ->
      fireball.direction.(fireball)
    end)
  end

  defp fireballs_collision(fireballs, board, snakes, apples) do
    Enum.map(fireballs, fn(current_fireball) ->
        Point.check_fireball_collision( # CZY KOLORY NA ZEWNATRZ ZMIENIAC
        current_fireball,
        board.width,
        board.height,
        snakes,
        apples,
        Enum.filter(fireballs, fn(filter_fireball) -> filter_fireball.id != current_fireball.id end)
      )
    end)
  end

  defp mark_fireballs(fireball_collision_checks) do
    fireball_collision_checks
      |> Enum.filter(fn({_map, status}) -> status != :fireball_ok end)
      |> Enum.map(fn({map, _status}) -> map.fireball.id end)
  end

  defp mark_apples(fireball_collision_checks) do
    fireball_collision_checks
    |> Enum.filter(fn({_map, status}) -> status == :fireball_apple_end end)
    |> Enum.map(fn({map, _status}) -> map.apple_collided.id end)
  end


  defp snakes_fireball_damage(fireball_collision_checks, snake_1, snake_2) do
    %{snake_1: snake1, snake_2: snake2} =
      fireball_collision_checks
      |> Enum.filter(fn({_map, status}) -> status == :fireball_snake_end end)
      |> Enum.reduce(%{snake_1: snake_1, snake_2: snake_2},
          fn({map, _status}, acc_map) ->
            {snake, collision_point} = map.snake_collided
            snake_id = snake.id

            snake = Map.get(acc_map, String.to_atom("snake_#{snake_id}"), %{})
            updated_snake = Snake.remove_blockdown(snake, collision_point.coordinates)
            updated_snake = %{updated_snake| apples: length(updated_snake.points), score: length(updated_snake.points) * 100}
            Map.put(acc_map, String.to_atom("snake_#{snake_id}"), updated_snake)
          end)
    {snake1, snake2}
  end

  def game_loop(socket) when socket.assigns.game_state.status in [:game_over, :game_start] do
    socket.assigns.game_state
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

    assigns = socket.assigns
    game_state = assigns.game_state
    snake_map = game_state.snake_map
    board = game_state.board
    apples = game_state.apples
    fireballs = game_state.fireballs
    next_apple_id = game_state.next_apple_id
    next_fireball_id = game_state.next_fireball_id  # TODO: UZYC TEGO!!
    fireball_ids_to_remove = game_state.fireball_ids_to_remove
    apple_ids_to_remove = game_state.apple_ids_to_remove
    iteration = game_state.iteration


    # AT THE STAR OF THE ITERATION, REMOVE USED UP OBJECTS
    apples = Enum.filter(apples, fn(apple) -> !Enum.member?(apple_ids_to_remove, apple.id) end)
    fireballs = Enum.filter(fireballs, fn(fireball) -> !Enum.member?(fireball_ids_to_remove, fireball.id) end)

    points_taken = Enum.map(fireballs, fn(x) -> x.coordinates end)
                  ++ Enum.map(apples, fn(x) -> x.coordinates end)
                  ++ Enum.map(snake_map.snake_1.snake.points, fn(x) -> x.coordinates end)
                  ++ Enum.map(snake_map.snake_2.snake.points, fn(x) -> x.coordinates end)

    {apples, next_apple_id} =
      case apples do
        [] ->
          cond do
            iteration < 10 ->
              {[Point.new_apple(next_apple_id, board.width, board.height, points_taken)], next_apple_id}
            true ->
              acc = {next_apple_id, points_taken}
              {apples, {next_apple_id, _}} =
                Enum.map_reduce(1..div(iteration, 10), acc, fn(_num, {apple_id, points_taken}) ->
                new_apple = Point.new_apple(apple_id, board.width, board.height, points_taken)
                {new_apple, {apple_id+1, [new_apple.coordinates|points_taken]}}
              end)
              {apples, next_apple_id}
          end
        _ ->
          {apples, next_apple_id}
      end

    # MOVE SNAKES
    snake_map = snakes_move(snake_map) # FIXME UNCOMMENT

    # MOVE FIREBALLS
    fireballs = fireballs_move(fireballs)

    # CHECK SNAKE COLLISIONS
    snake_statuses = snakes_collision(snake_map, board, apples)

    # ADD EATEN APPLES TO THE REMOVED SET
    eaten_apples =
      Enum.filter(snake_statuses, fn({status, _snake_id, _snake, _apple}) -> status == :game_food end)
      |> Enum.map(fn({_status, _snake_id, _snake, apple}) -> apple.id end)

    apple_ids_to_remove = eaten_apples

    [snake_1_status_tuple] = Enum.filter(snake_statuses, fn({_status, snake_id, _snake, _apple}) -> snake_id == 1 end)
    [snake_2_status_tuple] = Enum.filter(snake_statuses, fn({_status, snake_id, _snake, _apple}) -> snake_id == 2 end)

    snake_1 = elem(snake_1_status_tuple, 2)
    snake_2 = elem(snake_2_status_tuple, 2)

    snake_1_dead = elem(snake_1_status_tuple, 0) == :game_dead
    snake_2_dead = elem(snake_2_status_tuple, 0) == :game_dead

    # CHECK FIREBALL COLLISIONS
    fireball_collision_checks = fireballs_collision(fireballs, board, [snake_1]++[snake_2], apples)

    # MARK FIREBALLS FOR DELETION AT THE START OF A NEW ITERATION
    fireball_ids_to_remove = mark_fireballs(fireball_collision_checks)

    # MARK APPLES FOR DELETION AT THE START OF A NEW ITERATION
    apple_ids_to_remove = apple_ids_to_remove ++ mark_apples(fireball_collision_checks)

    # APPLY FIREBALL DAMAGE TO SNAKES USING 'Snake.remove_blockdown' AND SHORTEN THEIR TAILS
    {snake_1, snake_2} = snakes_fireball_damage(fireball_collision_checks, snake_1, snake_2)

    snake_1_dead = snake_1_dead or length(snake_1.points) == 0
    snake_2_dead = snake_2_dead or length(snake_2.points) == 0

    # TODO: 1. JESLI SNAKE ZYJE I CHCE STRZELIC TO STRZEL -> STWORZ FIREBALLA I SPRAWDZ ZNOWU KOLIZJE
    # TODO: 2. CHECK SNAKE_COLLISIONS I FIREBALL

    snake_map = %{snake_map| snake_1: %{snake_map.snake_1| snake: snake_1}}
    snake_map = %{snake_map| snake_2: %{snake_map.snake_2| snake: snake_2}}

    snake_map_extra = %{snake_map| snake_1: Map.put(snake_map.snake_1, :snake_dead, snake_1_dead)}
    snake_map_extra = %{snake_map_extra| snake_2: Map.put(snake_map.snake_2, :snake_dead, snake_2_dead)}

    reduce_acc = {snake_map_extra, next_fireball_id}

    # SPAWN NEW FIREBALLS IF NEEDED
    {new_fireballs, {snake_map, next_fireball_id}} =
      Enum.map_reduce(snake_map_extra, reduce_acc, fn({snake_name, snake_data}, {acc_map, fireball_id}) ->

        snake = snake_data.snake
        should_fire = snake_data.fire
        snake_dead = snake_data.snake_dead

        case should_fire do
          true when snake_dead != true and snake.fire != 0 ->
            snake = %{snake| fire: snake.fire - 1}
            updated_snake_data = %{snake_data| snake: snake, fire: false}
            acc_map = Map.put(acc_map, snake_name, updated_snake_data)
            {Snake.fire(snake, fireball_id), {acc_map, fireball_id + 1}}
          _ ->
            {nil, {acc_map, fireball_id}}
          end
      end)

    fireballs = fireballs ++ Enum.filter(new_fireballs, fn(new_fireball) -> new_fireball != nil end)

    snake_1 = snake_map.snake_1.snake
    snake_2 = snake_map.snake_2.snake

    # CHECK FIREBALL COLLISIONS
    fireball_collision_checks = fireballs_collision(fireballs, board, [snake_1]++[snake_2], apples)

    # MARK FIREBALLS FOR DELETION AT THE START OF A NEW ITERATION
    fireball_ids_to_remove = mark_fireballs(fireball_collision_checks)

    # MARK APPLES FOR DELETION AT THE START OF A NEW ITERATION
    apple_ids_to_remove = apple_ids_to_remove ++ mark_apples(fireball_collision_checks)  # FIXME : NADPISANE BEDZIE DODAC EATEN APPLES??

    # APPLY FIREBALL DAMAGE TO SNAKES USING 'Snake.remove_blockdown' AND SHORTEN THEIR TAILS
    {snake_1, snake_2} = snakes_fireball_damage(fireball_collision_checks, snake_1, snake_2)

    snake_1_dead = snake_1_dead or length(snake_1.points) == 0
    snake_2_dead = snake_2_dead or length(snake_2.points) == 0

    snake_map = %{snake_map| snake_1: %{snake_map.snake_1| snake: snake_1}}
    snake_map = %{snake_map| snake_2: %{snake_map.snake_2| snake: snake_2}}

    game_status =
      case {snake_1_dead, snake_2_dead} do
        {false, false} ->
          :game_ok
        {_, _} ->
          :game_over
      end

    %{
      snake_map: snake_map,
      board: board,
      apples: apples,
      fireballs: fireballs,
      next_apple_id: next_apple_id + 1,
      next_fireball_id: next_fireball_id + 1,
      fireball_ids_to_remove: fireball_ids_to_remove,
      apple_ids_to_remove: apple_ids_to_remove,
      iteration: iteration + 1,
      status: game_status
    }
  end

end
