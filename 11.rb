# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './coordinates.rb'
require './11_test_data.rb'

module State
  FLOOR = '.'
  EMPTY = 'L'
  OCCUPIED = '#'
end

# converts a sequence of lines into a Flat::Grid object
def to_grid(lines)
  lines = lines.split("\n") if lines.is_a?(String)
  Flat::Grid.from_lines(lines) {|char, _, _| {state: char}}
end

# returns a hash of all the changes that we should make to a given coordinate
def calculate_changes(grid, empty_if_greater, occupied_counter)
  grid.points.keys.each_with_object({}) do |coordinate, changes|
    seat_state = grid.at(coordinate)[:state]
    if seat_state != State::FLOOR
      occupied_count = occupied_counter.call(grid, coordinate)
      changes[coordinate] = State::OCCUPIED if occupied_count == 0 && seat_state == State::EMPTY
      changes[coordinate] = State::EMPTY if occupied_count >= empty_if_greater && seat_state == State::OCCUPIED
    end
  end
end

# loops through iterations of the cycle until we have no further changes at
# which coordinate it returns a count of the coordinates which are occupied
def stabilize(grid, empty_if_greater, occupied_counter)
  while (changes = calculate_changes(grid, empty_if_greater, occupied_counter)) && changes.any?
    changes.each {|coordinate, change| grid.set(coordinate, :state, change)}
  end
  grid.select(:state, State::OCCUPIED).length
end


AoC.part 1, clear_screen: true do
  count_occupied = proc do |grid, coordinate|
    grid.neighbors(coordinate, :state, State::OCCUPIED, Flat::Directions::Adjacent).length
  end

  Assert.equal 37, stabilize(to_grid(TEST_DATA), 4, count_occupied)
  stabilize(to_grid(AoC::IO.input_file), 4, count_occupied)
end


AoC.part 2 do
  count_occupied = proc do |grid, coordinate|
    Flat::Directions::Adjacent.count do |direction|
      target = coordinate
      while (target = target.move(direction))
        break false if !grid.contains?(target)
        break true if grid.at(target)[:state] == State::OCCUPIED
        break false if grid.at(target)[:state] == State::EMPTY
      end
    end
  end

  Assert.equal 8, count_occupied.call(to_grid(TEST_VISIBILITY_DATA_ONE), Flat::Coordinate.new(3, 4))
  Assert.equal 0, count_occupied.call(to_grid(TEST_VISIBILITY_DATA_TWO), Flat::Coordinate.new(1, 1))
  Assert.equal 0, count_occupied.call(to_grid(TEST_VISIBILITY_DATA_THREE), Flat::Coordinate.new(3, 3))
  Assert.equal 26, stabilize(to_grid(TEST_DATA), 5, count_occupied)
  stabilize(to_grid(AoC::IO.input_file), 5, count_occupied)
end
