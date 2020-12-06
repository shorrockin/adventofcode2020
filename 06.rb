# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

groups = ARGF.read.split("\n\n")

AoC.part 1, clear_screen: true do
  groups.sum {|line| line.scan(/[a-z]/).uniq.length}
end

AoC.part 2 do
  groups.sum {|line| line.split("\n").map(&:chars).inject(&:&).length}
end
