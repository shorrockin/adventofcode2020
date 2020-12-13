# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './coordinates.rb'

AoC.part 1, clear_screen: true do
  def find_earliest(earliest, bus_ids)
    time = earliest
    bus_ids = bus_ids.reject {|id| id == 'x'}.map(&:to_i)
    time += 1 while bus_ids.none? {|id| time % id == 0}
    (time - earliest) * bus_ids.find {|id| time % id == 0}
  end

  example_departure = 939
  example_bus_ids = "7,13,x,x,59,x,31,19".split(',')
  Assert.equal 295, find_earliest(example_departure, example_bus_ids)

  earliest_departure = AoC::IO.input_file[0].to_i
  bus_ids = AoC::IO.input_file[1].split(',')
  find_earliest(earliest_departure, bus_ids)
end

AoC.part 2 do
  def extended_gcd(a, b)
    last_remainder, remainder = a.abs, b.abs
    x, last_x, y, last_y = 0, 1, 1, 0

    while remainder != 0
      last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
      x, last_x = last_x - quotient * x, x
      y, last_y = last_y - quotient * y, y
    end

    [last_remainder, last_x * (a < 0 ? -1 : 1)]
  end
  
  def invmod(e, et)
    g, x = extended_gcd(e, et)
    raise 'Multiplicative inverse modulo does not exist!' if g != 1
    x % et
  end

  def chinese_remainder(mods, remainders)
    max = mods.inject(&:*) # product of all moduli
    series = remainders.zip(mods).map {|r,m| (r * max * invmod(max / m, m) / m)}
    series.inject(&:+) % max
  end

  def earliest_time(bus_ids)
    ids = bus_ids.each_with_index
      .map {|id, idx| [id, idx]}
      .reject {|id, _| id == 'x'}

    mods = ids.map {|id, _| id.to_i}
    remainders = ids.map {|id, idx| id.to_i - idx}

    chinese_remainder(mods, remainders)
  end

  Assert.equal 3417, earliest_time([17,'x',13,19])
  Assert.equal 754018, earliest_time([67,7,59,61])

  earliest_time(AoC::IO.input_file[1].split(','))
end
