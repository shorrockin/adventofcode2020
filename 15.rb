# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def play_game(numbers, total_turns)
  raise "stop being lazy and init last_used properly" if numbers.uniq.length != numbers.length
  last_used = numbers.each_with_index.to_h

  turn = numbers.length
  next_used = numbers.last
  next_used_previous_index = nil

  while turn < total_turns
    new_value = next_used_previous_index.nil? ? 0 : (turn - next_used_previous_index - 1)

    next_used_previous_index = last_used[new_value] # store a record of when next_used was last used
    last_used[new_value] = turn                     # record it for future usages
    next_used = new_value                           # save the next used for the next iteration

    turn += 1
  end

  next_used
end

AoC.part 1, clear_screen: true do
  Assert.equal 436, play_game([0, 3, 6], 2020)
  play_game([0, 3, 1, 6, 7, 5], 2020)
end

AoC.part 2 do
  play_game([0, 3, 1, 6, 7, 5], 30_000_000)
end
