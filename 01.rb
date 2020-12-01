# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

AoC.part 1, clear_screen: true do
  AoC::IO.input_file
    .map(&:to_i)
    .permutation(2)
    .find {|a, b| a + b == 2020}
    .inject(&:*)
end

AoC.part 2 do
  AoC::IO.input_file
    .map(&:to_i)
    .permutation(3)
    .find {|a, b, c| a + b + c == 2020}
    .inject(&:*)
end
