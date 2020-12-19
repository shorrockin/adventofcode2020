# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './19_test_data.rb'

def solve(lines, rules={})
  messages = []

  lines.each do |line|
    if (match = line.match(/([0-9]+): (.*)/))
      id, rule = match.captures
      rules[id] ||= rule.tr('"', "")
    elsif line.match?(/[ab].*/)
      messages << line
    end
  end

  rule = Regexp.new("^(?<g0>#{reduce_rule(rules['0'], rules, ['0'])})$")
  messages.count {|m| m.match?(rule)}
end

def reduce_rule(value, rules, history=[])
  value.split(" ").map do |char|
    if 'ab|'.include?(char)
      char
    elsif 'ab'.include?(rules[char])
      rules[char]
    elsif !history.include?(char)
      "(?<g#{char}>#{reduce_rule(rules[char], rules, history << char)})"
    elsif history.include?(char)
      "\\g<g#{char}>"
    end
  end.join('')
end


AoC.part 1, clear_screen: true do
  Assert.equal 2, solve(EXAMPLE_PART_ONE.split("\n"))
  solve(AoC::IO.input_file)
end

AoC.part 2 do
  OVERRIDES = {
    '8' => '42 | 42 8',
    '11' => '42 31 | 42 11 31',
  }

  Assert.equal 12, solve(EXAMPLE_PART_TWO.split("\n"), OVERRIDES.dup)
  solve(AoC::IO.input_file, OVERRIDES.dup)
end
