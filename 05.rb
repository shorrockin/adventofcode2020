# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def read_boarding_pass(value); value.tr("FRBL", "0110").to_i(2); end
boarding_passes = AoC::IO.input_file.map {|line| read_boarding_pass(line)}.sort

AoC.part 1, clear_screen: true do
  Assert.equal 567, read_boarding_pass("BFFFBBFRRR")
  Assert.equal 119, read_boarding_pass("FFFBBBFRRR")
  Assert.equal 820, read_boarding_pass("BBFFBBFRLL")
  boarding_passes.last
end

AoC.part 2 do
  neighbor_seat, _ = boarding_passes.each_with_index.find {|seat, idx| (boarding_passes[idx + 1] - seat) == 2}
  neighbor_seat + 1
end
