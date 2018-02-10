defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do
      game =
        Game.new_game()
        |> Map.put(:game_state, state)

      assert ^game = Game.make_move(game, "x")
    end
  end

  test "first occurrence of letter is not already used" do
    game = Game.new_game()

    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
  end

  test "second occurrence of letter is already used" do
    game = Game.new_game()

    game = Game.make_move(game, "x")
    assert game.game_state != :already_used
    game = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "a good guess is recognized" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
  end

  test "a guessed word is a won game" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "w")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "i")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "b")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "l")
    assert game.game_state == :good_guess
    assert game.turns_left == 7
    game = Game.make_move(game, "e")
    assert game.game_state == :won
    assert game.turns_left == 7
  end

  test "a bad guess is recognized" do
    game = Game.new_game("wibble")
    game = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "too many bad guesses makes you lose" do
    moves = [
      {"a", :bad_guess},
      {"b", :bad_guess},
      {"c", :bad_guess},
      {"d", :bad_guess},
      {"e", :bad_guess},
      {"f", :bad_guess},
      {"g", :lost}
    ]

    moves
    |> Enum.reduce({Game.new_game("w"), 6}, fn {letter, expected_state},
                                               {game, expected_turns_left} ->
      %Game{turns_left: turns_left, game_state: game_state} = game = Game.make_move(game, letter)

      case game_state do
        :lost -> :ok
        _ -> assert turns_left == expected_turns_left
      end

      assert game_state == expected_state

      {game, expected_turns_left - 1}
    end)
  end
end
