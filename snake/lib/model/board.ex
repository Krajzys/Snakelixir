defmodule Model.Board do
  defstruct [
    width: 0,
    height: 0,
    snakes: [], # CZY SNAKES I APPLES SA POTRZEBNE??
    apples: [],
    points_taken: []
  ]

  def new(options \\ []) do
    __struct__(options)
  end

  # def new_params(width, height, snakes, apples, points_taken) do
  #   %{
  #     width: width,
  #     height: height,
  #     snakes: [],
  #     apples: [],
  #     points_taken: []
  #   }
  # end
  # APPLE SPAWNING

end
