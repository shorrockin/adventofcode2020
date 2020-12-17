# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './conway.rb'

class Grid < Conway
  def calculate_change(coordinate)
    active = @coordinates[coordinate]
    active_neighbors_count = active_neighbors(coordinate).length

    if active && active_neighbors_count != 2 && active_neighbors_count != 3
      [coordinate, false]
    elsif !active && active_neighbors_count == 3
      [coordinate, true]
    end
  end
end

EXAMPLE_GRID = <<~TEST_DATA
  .#.
  ..#
  ###
TEST_DATA

AoC.part 1, clear_screen: true do
  Assert.equal 112, Grid.new(EXAMPLE_GRID.split("\n"), 3).cycle.active_coordinates.length
  Grid.new(AoC::IO.input_file, 3).cycle.active_coordinates.length
end

AoC.part 2 do
  Assert.equal 848, Grid.new(EXAMPLE_GRID.split("\n"), 4).cycle.active_coordinates.length
  Grid.new(AoC::IO.input_file, 4).cycle.active_coordinates.length
end
