# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './20_test_data.rb'
require './memoize.rb'
require 'benchmark'

Orientation = Struct.new(:rotations, :flipped)
ORIENTATIONS = 8.times.map {|i| Orientation.new(i % 4, i <= 3)}

class Tile
  include RubyMemoized
  NORTH = 0
  EAST = 1
  SOUTH = 2
  WEST = 3

  attr_accessor :id, :lines, :grid_size

  def initialize(lines, grid_size)
    @id = lines[0].scan(/Tile ([0-9]+):/)[0][0].to_i
    @lines = lines[1..lines.length].map(&:chars)
    @grid_size = grid_size
  end

  def self.part_one(lines)
    tiles, _ = arranged(lines)
    grid_size = tiles.first.grid_size

    tiles.first.id * tiles.last.id * tiles[grid_size - 1].id * tiles[tiles.length - grid_size].id
  end

  def self.part_two(lines, shape_coords)
    tiles, orientations = arranged(lines)
    grid_size = tiles.first.grid_size
    combined = ""

    grid_size.times do |row|
      10.times do |line_number|
        next if line_number == 0 || line_number == 9

        grid_size.times do |column_number|
          index = (row * grid_size) + column_number
          combined += tiles[index].orient(orientations[index])[line_number][1..8].join
        end
        combined += "\n"
      end
    end

    combined = Tile.new(("Tile 1:\n" + combined).split("\n"), 1)

    ORIENTATIONS.map do |orientation|
      lines = combined.orient(orientation)

      lines.each_with_index.sum do |line, line_num|
        line.each_with_index.count do |char, char_num|
          if char == "#"
            matches_shape = shape_coords.all? do |shape_line_offset, shape_char_offset|
              line_coord = (line_num + shape_line_offset)
              char_coord = (char_num + shape_char_offset)
              line_coord >= 0 && line_coord < lines.length && char_coord >= 0 && char_coord < line.length && lines[line_coord][char_coord] == '#'
            end

            if matches_shape
              shape_coords.each do |shape_line_offset, shape_char_offset|
                line_coord = (line_num + shape_line_offset)
                char_coord = (char_num + shape_char_offset)
                lines[line_coord][char_coord] = 'O'
              end
            end

            matches_shape
          end
        end
      end

      lines.sum do |line|
        line.count {|c| c == '#'}
      end
    end.min
  end

  def self.arranged(lines)
    tiles = lines.split("\n\n")
    tiles = tiles.map {|l| Tile.new(l.split("\n"), Math.sqrt(tiles.length).to_i)}
    find_next(tiles, [], [])
  end

  private_class_method def self.find_next(tiles, previous_tiles, previous_orientations)
    # we've found our solution
    if previous_tiles.length == tiles.length
      return [previous_tiles, previous_orientations]
    end

    (tiles - previous_tiles).each do |tile|
      ORIENTATIONS.each do |orientation|
        # if this is our first tile then just run with it
        if previous_tiles.empty? && (solution = find_next(tiles, previous_tiles + [tile], previous_orientations + [orientation]))
          return solution
        end

        matches_west = (previous_tiles.length % tile.grid_size == 0)
        matches_west ||= (tile.side(WEST, orientation) == previous_tiles.last.side(EAST, previous_orientations.last))

        if matches_west
          north_index = (previous_tiles.length - tile.grid_size)
          matches_north = north_index < 0
          matches_north ||= (tile.side(NORTH, orientation) == previous_tiles[north_index].side(SOUTH, previous_orientations[north_index]))

          if matches_north && (solution = find_next(tiles, previous_tiles + [tile], previous_orientations + [orientation]))
            return solution
          end
        end
      end
    end

    raise "could not find solution, :wompwomp:" if previous_tiles.empty?
    nil
  end

  memoized
  def orient(orientation)
    orientation.rotations.times.reduce(orientation.flipped ? @lines.map(&:reverse) : @lines) do |rotated|
      rotated.transpose.map(&:reverse)
    end
  end

  def side(side, orientation)
    modified_lines = orient(orientation)
    case side
    when NORTH then modified_lines.first
    when EAST then modified_lines.map(&:last)
    when SOUTH then modified_lines.last
    when WEST then modified_lines.map(&:first)
    end
  end
end

AoC.part 1, clear_screen: true do
  Assert.equal 20899048083289, Tile.part_one(EXAMPLE)
  Tile.part_one(AoC::IO.input_file.join("\n"))
end

AoC.part 2 do
  shape = ["                  X ", "#    ##    ##    ###", " #  #  #  #  #  #   "]
  start = [0, 18]
  shape_offsets = [[0, 0]] + shape.each_with_index.map do |line, line_num|
    line.chars.each_with_index.map do |char, char_num|
      if char == "#"
        [line_num, char_num - start[1]]
      end
    end
  end.flatten(1).compact

  Assert.equal 273, Tile.part_two(EXAMPLE, shape_offsets)
  Tile.part_two(AoC::IO.input_file.join("\n"), shape_offsets)
end
