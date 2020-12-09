# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def part_one(numbers, preamble=25)
  numbers.length.times do |index|
    next if index < preamble

    target = numbers[index]
    candidates = numbers[(index - preamble)..(index - 1)]

    return target unless candidates.any? {|v| candidates.include?(target - v)}
  end
end

def part_two(target, numbers)
  numbers.length.times do |start_index|
    sum = 0

    numbers[start_index..numbers.length].each_with_index do |current_value, end_index|
      sum += current_value

      if sum == target
        solution_range = numbers[start_index..(start_index + end_index)]
        return solution_range.min + solution_range.max
      elsif sum > target
        break
      end
    end
  end
end

input = AoC::IO.input_file.map(&:to_i)

AoC.part 1, clear_screen: true do
  part_one(input)
end

AoC.part 2 do
  part_two(part_one(input), input)
end
