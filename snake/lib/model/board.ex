defmodule Model.Board do
  defstruct [
    width: 0,
    height: 0,
    snakes: [],
    apples: [],
    points_taken: []
  ]

  def new(options \\ []) do
    __struct__(options)
  end
end
