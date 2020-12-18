# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def sum_lines(lines, prioritize_addition=false)
  lines.sum do |line|
    # extract each bracketed expression, evaluate them individually then replace
    # results in the string.
    while (expression = line.match(/\([0-9\+\-\*\s]+\)/))
      line = line.gsub(expression.to_s, eval_expression(expression.to_s, prioritize_addition).to_s)
    end

    # now that we've removed all the nested brackets evaluate the remaining expression
    eval_expression(line, prioritize_addition)
  end
end

def eval_expression(expression, prioritize_addition=false)
  expression = expression.tr('()', '')

  # if we're prioritizing addition, then look for instances of these first
  # extract and evaluation the expression, replacing them inline.
  if prioritize_addition
    while (addition = expression.match(/([0-9]+) \+ ([0-9]+)/))
      expression = expression.sub(addition.to_s, addition.captures.sum(&:to_i).to_s)
    end
  end

  # iterate left to right evaluating the expression, each component will either
  # be an operator or a value.
  expression.split(' ').reduce([nil, nil]) do |(current_val, next_oper), component|
    if component == '+'
      [current_val, :+]
    elsif component == '*'
      [current_val, :*]
    elsif current_val.nil?
      [component.to_i, nil]
    else
      [current_val.send(next_oper, component.to_i), nil]
    end
  end.first
end

AoC.part 1, clear_screen: true do
  Assert.equal 26, sum_lines(["2 * 3 + (4 * 5)"])
  Assert.equal 437, sum_lines(["5 + (8 * 3 + 9 + 3 * 4 * 3)"])
  Assert.equal 12240, sum_lines(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"])
  Assert.equal 13632, sum_lines(["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"])
  sum_lines(AoC::IO.input_file) # should == 67800526776934
end

AoC.part 2 do
  Assert.equal 231, sum_lines(["1 + 2 * 3 + 4 * 5 + 6"], true)
  Assert.equal 51, sum_lines(["1 + (2 * 3) + (4 * (5 + 6))"], true)
  Assert.equal 46, sum_lines(["2 * 3 + (4 * 5)"], true)
  Assert.equal 97, sum_lines(["1 + (2 * 3) + (4 * (5 + 6))", "2 * 3 + (4 * 5)"], true)
  Assert.equal 1445, sum_lines(["5 + (8 * 3 + 9 + 3 * 4 * 3)"], true)
  Assert.equal 669060, sum_lines(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"], true)
  Assert.equal 23340, sum_lines(["(((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2)"], true)
  Assert.equal 30, sum_lines(["(5 + 7 + 3 + 6 + 6 + 3)"], true)
  Assert.equal 16562700, sum_lines(["5 * (9 + 3) * 7 + ((4 + 4 * 8) * (4 * 7) * (6 + 5) + 3) * 6 + 5"], true)
  Assert.equal 12936, sum_lines(["(3 * 7 + 5 + (2 + 9 + 7 + 9) + 5) * 5 + 2 * 5 + 9"], true)
  sum_lines(AoC::IO.input_file, true) # should == 340789638435483
end
