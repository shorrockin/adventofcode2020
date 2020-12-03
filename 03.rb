# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './coordinates.rb'

Slope = Struct.new(:x, :y)
SLOPES = [
  Slope.new(1, 1),
  Slope.new(3, 1), # Part 1
  Slope.new(5, 1),
  Slope.new(7, 1),
  Slope.new(1, 2),
]

def trees_on_slope(slope)
  position = Flat::Coordinate.new(0, 0)
  count    = 0
  map      = AoC::IO.input_file

  while position.y < map.length
    count += 1 if map[position.y][position.x % map[position.y].length] == '#'
    position = position.move(slope)
  end

  count
end

AoC.part 1, clear_screen: true do
  trees_on_slope(SLOPES[1])
end

AoC.part 2 do
  SLOPES.map {|v| trees_on_slope(v)}.inject(&:*)
end
