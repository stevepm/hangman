defmodule Hangman do
  alias Hangman.Server

  def new_game() do
    {:ok, pid} = Server.start_link()
    pid
  end

  def tally(game) do
    GenServer.call(game, {:tally})
  end

  def make_move(game, guess) do
    GenServer.call(game, {:make_move, guess})
  end
end
