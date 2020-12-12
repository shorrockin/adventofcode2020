# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './coordinates.rb'

class Ship
  attr_accessor :facing, :position, :waypoint
  def initialize(instructions)
    @position = Flat::Coordinate.new(0, 0)
    @facing = Flat::Directions::East
    @waypoint = Flat::Coordinate.new(10, -1)

    instructions.each do |instruction|
      instruction.execute(self)
    end
  end

  def distance(from=Flat::Coordinate.new(0, 0))
    @position.distance(from)
  end
end

class Instruction
  def initialize(action, value, part_one)
    @action = action
    @value = value
    @part_one = part_one
  end

  def self.parse(part_one, lines)
    lines = lines.split("\n") if lines.is_a?(String)
    lines.map do |line|
      _, action, value = line.split(/([A-Z]{1})([0-9]{0,3})/)
      Instruction.new(action, value.to_i, part_one)
    end
  end

  def execute(ship)
    if @part_one
      case @action
      when "N" then ship.position = ship.position.move(Flat::Directions::North, @value)
      when "S" then ship.position = ship.position.move(Flat::Directions::South, @value)
      when "E" then ship.position = ship.position.move(Flat::Directions::East, @value)
      when "W" then ship.position = ship.position.move(Flat::Directions::West, @value)
      when "L" then (@value / 90).times {ship.facing = Flat::Coordinate.new(ship.facing.y, ship.facing.x * -1)}
      when "R" then (@value / 90).times {ship.facing = Flat::Coordinate.new(ship.facing.y * -1, ship.facing.x)}
      when "F" then ship.position = ship.position.move(ship.facing, @value)
      else; raise "unknown action: #{@action}"
      end
    else
      case @action
      when "N" then ship.waypoint = ship.waypoint.move(Flat::Directions::North, @value)
      when "S" then ship.waypoint = ship.waypoint.move(Flat::Directions::South, @value)
      when "E" then ship.waypoint = ship.waypoint.move(Flat::Directions::East, @value)
      when "W" then ship.waypoint = ship.waypoint.move(Flat::Directions::West, @value)
      when "L" then (@value / 90).times {ship.waypoint = Flat::Coordinate.new(ship.waypoint.y, ship.waypoint.x * -1)}
      when "R" then (@value / 90).times {ship.waypoint = Flat::Coordinate.new(ship.waypoint.y * -1, ship.waypoint.x)}
      when "F" then ship.position = Flat::Coordinate.new(ship.position.x + (ship.waypoint.x * @value), ship.position.y + (ship.waypoint.y * @value))
      else; raise "unknown action: #{@action}"
      end
    end
  end

  def to_s; "Instruction<#{@action} #{@value}>"; end
end

AoC.part 1, clear_screen: true do
  test_instructions = Instruction.parse true, <<~TEST_DATA
    F10
    N3
    F7
    R90
    F11
  TEST_DATA
  Assert.equal 25, Ship.new(test_instructions).distance

  Ship.new(Instruction.parse(true, AoC::IO.input_file)).distance
end

AoC.part 2 do
  test_instructions = Instruction.parse false, <<~TEST_DATA
    F10
    N3
    F7
    R90
    F11
  TEST_DATA
  Assert.equal 286, Ship.new(test_instructions).distance

  Ship.new(Instruction.parse(false, AoC::IO.input_file)).distance
end
