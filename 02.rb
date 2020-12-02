# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

Rule = Struct.new(:left, :right, :letter, :password)
RULES = AoC::IO.input_file.map do |line|
  left, right, letter, password = line.match(/(\d+)-(\d+) (\w+): (.*)/).captures
  Rule.new(left.to_i, right.to_i, letter, password)
end

AoC.part 1, clear_screen: true do
  RULES.count do |rule|
    count = rule.password.count(rule.letter)
    count >= rule.left && count <= rule.right
  end
end

AoC.part 2 do
  RULES.count do |rule|
    matches_left = (rule.password[rule.left - 1] == rule.letter)
    matches_right = (rule.password[rule.right - 1] == rule.letter)
    matches_left ^ matches_right
  end
end
