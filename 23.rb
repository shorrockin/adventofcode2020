# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

class Cup
  attr_accessor :value, :next
  def initialize(value)
    @value = value
  end

  def add(next_card)
    self.next = next_card
    next_card
  end

  def remove_three
    removed_next = self.next
    self.next = self.next.next.next.next
    [removed_next, [removed_next.value, removed_next.next.value, removed_next.next.next.value]]
  end

  def add_three(head)
    current_next = self.next
    self.next = head
    head.next.next.next = current_next
  end
end

def solve(input, part_one)
  numbers = input.to_s.chars.map(&:to_i)
  min_value = numbers.min
  max_value = part_one ? numbers.max : 1_000_000

  lookup = {}
  lookup[numbers[0]] = current = Cup.new(numbers[0])
  last = numbers[1..numbers.length].reduce(current) do |previous, value|
    lookup[value] = previous.add(Cup.new(value))
  end

  if !part_one
    last = (1_000_000 - numbers.length).times.reduce(last) do |previous, value|
      lookup[value + numbers.length + 1] = previous.add(Cup.new(value + numbers.length + 1))
    end
  end

  last.next = current

  (part_one ? 100 : 10_000_000).times do
    removed, removed_values = current.remove_three

    destination = current.value - 1
    destination = max_value if destination == 0

    while removed_values.include?(destination)
      destination -= 1
      destination = max_value if destination < min_value
    end

    lookup[destination].add_three(removed)
    current = current.next
  end

  if part_one
    next_cup = lookup[1]
    (numbers.length - 1).times.reduce("") {|str, _| next_cup = next_cup.next; str + next_cup.value.to_s}
  else
    lookup[1].next.value * lookup[1].next.next.value
  end
end

AoC.part 1, clear_screen: true do
  Assert.equal "67384529", solve(389125467, true)
  solve(467528193, true)
end

AoC.part 2 do
  Assert.equal 149245887792, solve(389125467, false)
  solve(467528193, false)
end
