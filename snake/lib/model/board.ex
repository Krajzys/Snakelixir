defmodule Snake.Board do
  defstruct [
    width: 0,
    height: 0,
    snakes: [],
    apples: []
  ]

  def new() do
    __struct__()
  end
  # APPLE SPAWING

end
