defmodule Snake.Board do
  defstruct [
    width: 0,
    height: 0,
    snakes: [],
    apples: [],
    points_taken: []
  ]

  def new() do
    __struct__()
  end
  # APPLE SPAWNING

end
