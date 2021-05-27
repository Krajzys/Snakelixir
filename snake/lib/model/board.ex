defmodule Model.Board do
  defstruct [
    width: 0,
    height: 0,
    snakes: [], # CZY SNAKES I APPLES SA POTRZEBNE??
    apples: [],
    points_taken: []
  ]

  def new() do
    __struct__()
  end

  def new_params(width \\ 10, height \\ 10, snakes \\ [], apples \\ [], points_taken \\ []) do
    %{
      width: width,
      height: height,
      snakes: snakes,
      apples: apples,
      points_taken: points_taken
    }
  end
  # APPLE SPAWNING

end
