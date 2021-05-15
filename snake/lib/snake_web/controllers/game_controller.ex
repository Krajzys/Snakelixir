defmodule SnakeWeb.GameController do
  use SnakeWeb, :controller

  alias Phoenix.LiveView
  alias SnakeWeb.Live.Game

  def index(conn, _) do
    opts = [
      session: %{"cookies" => conn.cookies}
    ]

    LiveView.Controller.live_render(conn, Game, opts)
  end
end
