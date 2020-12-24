# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

Hex = Struct.new(:x, :y) do
  def move(direction)
    case direction
    when 'nw' then Hex.new(x, y - 1)
    when 'w' then Hex.new(x - 1, y)
    when 'sw' then Hex.new(x - 1, y + 1)
    when 'se' then Hex.new(x, y + 1)
    when 'e' then Hex.new(x + 1, y)
    when 'ne' then Hex.new(x + 1, y - 1)
    else; raise "invalid direction: #{direction}"
    end
  end

  def adjacent; ['nw', 'w', 'sw', 'se', 'e', 'ne'].map {|d| move(d)}; end
end

def solve(lines, part_one)
  flipped = {}
  direction_lines = lines.map {|line| line.scan(/nw|w|sw|se|e|ne/)}
  direction_lines.each do |directions|
    current = directions.inject(Hex.new(0, 0)) {|hex, dir| hex.move(dir)}
    flipped[current].nil? ? flipped[current] = true : flipped.delete(current)
  end

  return flipped.length if part_one

  100.times do
    adjacent_counts = flipped.keys.each_with_object({}) do |hex, counts|
      counts[hex] ||= 0
      hex.adjacent.each {|h| counts[h] = (counts.fetch(h, 0) + 1)}
    end

    adjacent_counts.each do |hex, count|
      if !flipped[hex].nil? && (count == 0 || count > 2)
        flipped.delete(hex)
      elsif flipped[hex].nil? && count == 2
        flipped[hex] = true
      end
    end
  end

  flipped.length
end

EXAMPLE = <<~EXAMPLE
  sesenwnenenewseeswwswswwnenewsewsw
  neeenesenwnwwswnenewnwwsewnenwseswesw
  seswneswswsenwwnwse
  nwnwneseeswswnenewneswwnewseswneseene
  swweswneswnenwsewnwneneseenw
  eesenwseswswnenwswnwnwsewwnwsene
  sewnenenenesenwsewnenwwwse
  wenwwweseeeweswwwnwwe
  wsweesenenewnwwnwsenewsenwwsesesenwne
  neeswseenwwswnwswswnw
  nenwswwsewswnenenewsenwsenwnesesenew
  enewnwewneswsewnwswenweswnenwsenwsw
  sweneswneswneneenwnewenewwneswswnese
  swwesenesewenwneswnwwneseswwne
  enesenwswwswneneswsenwnewswseenwsese
  wnwnesenesenenwwnenwsewesewsesesew
  nenewswnwewswnenesenwnesewesw
  eneswnwswnwsenenwnwnwwseeswneewsenese
  neswnwewnwnwseenwseesewsenwsweewe
  wseweeenwnesenwwwswnew
EXAMPLE

AoC.part 1, clear_screen: true do
  Assert.equal(10, solve(EXAMPLE.split("\n"), true))
  solve(AoC::IO.input_file, true)
end

AoC.part 2 do
  Assert.equal(2208, solve(EXAMPLE.split("\n"), false))
  solve(AoC::IO.input_file, false)
end
