defmodule Hangman.Game do
  alias Hangman.Game

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  def new_game() do
    Dictionary.random_word()
    |> new_game()
  end

  def new_game(word) do
    %Game{
      letters:
        word
        |> String.codepoints()
    }
  end

  def make_move(%Game{game_state: state} = game, _guess)
      when state in [:won, :lost] do
    game
  end

  def make_move(%Game{used: used} = game, guess) do
    accept_move(game, guess, MapSet.member?(used, guess))
  end

  def tally(%Game{
        game_state: game_state,
        turns_left: turns_left,
        letters: letters,
        used: used
      }) do
    %{
      game_state: game_state,
      turns_left: turns_left,
      letters:
        letters
        |> reveal_guessed(used)
    }
  end

  defp accept_move(%Game{} = game, _guess, true) do
    %{game | game_state: :already_used}
  end

  defp accept_move(%Game{used: used, letters: letters} = game, guess, false) do
    %{game | used: MapSet.put(used, guess)}
    |> score_guess(Enum.member?(letters, guess))
  end

  defp score_guess(%Game{letters: letters, used: used} = game, true) do
    new_state =
      letters
      |> MapSet.new()
      |> MapSet.subset?(used)
      |> maybe_won?()

    %{game | game_state: new_state}
  end

  defp score_guess(%Game{turns_left: 1} = game, false) do
    %{game | game_state: :lost}
  end

  defp score_guess(%Game{turns_left: turns_left} = game, false) do
    %{game | turns_left: turns_left - 1, game_state: :bad_guess}
  end

  defp score_guess(%Game{} = game, false) do
    game
  end

  defp maybe_won?(true) do
    :won
  end

  defp maybe_won?(false) do
    :good_guess
  end

  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter ->
      reveal_letter(letter, MapSet.member?(used, letter))
    end)
  end

  defp reveal_letter(letter, true) do
    letter
  end

  defp reveal_letter(_, false) do
    "_"
  end
end
