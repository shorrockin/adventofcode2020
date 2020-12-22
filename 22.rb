# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require 'benchmark'

def solve(lines, recursive)
  player_one = []
  player_two = []
  current_player = player_one

  lines.each do |line|
    current_player << line.to_i if line.match?(/^([0-9]+)$/)
    current_player = player_two if line == "Player 2:"
  end

  play_round(player_one, player_two, recursive)
  (player_one + player_two).reverse.each_with_index.sum {|v, i| v * (i + 1)}
end

def play_round(player_one, player_two, recursive)
  history = Set.new

  while player_one.length != 0 && player_two.length != 0
    return true if (history_key = [player_one, player_two]) && history.include?(history_key)
    history << history_key

    card_one = player_one.shift
    card_two = player_two.shift

    player_one_won = if recursive && (player_one.length >= card_one && player_two.length >= card_two)
      sub_deck_one = player_one[0...card_one]
      sub_deck_two = player_two[0...card_two]
      play_round(sub_deck_one, sub_deck_two, true) || sub_deck_two.length == 0
    else
      card_one > card_two
    end

    if player_one_won
      player_one << card_one
      player_one << card_two
    else
      player_two << card_two
      player_two << card_one
    end
  end
end

AoC.part 1, clear_screen: true do
  solve(AoC::IO.input_file, false)
end

AoC.part 2 do
  solve(AoC::IO.input_file, true)
end
