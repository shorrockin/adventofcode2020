# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

class AbstractProgram
  MASK_LENGTH = 36

  def initialize(lines)
    @mask = nil
    @memory = {}

    lines.each do |line|
      if line.start_with?('mask')
        @mask = line.match(/mask = ([X01]{36})/).captures.first
      else
        address, value = line.match(/mem\[([0-9]+)\] = ([0-9]+)/).captures
        execute(address.to_i, value.to_i)
      end
    end
  end

  def sum
    @memory.values.sum
  end
end

class PartOneProgram < AbstractProgram
  def execute(address, value)
    binary_value = value.to_s(2).rjust(MASK_LENGTH, '0')
    @mask.chars.each_with_index do |mask_val, idx|
      case mask_val
      when '1' then binary_value[idx] = '1'
      when '0' then binary_value[idx] = '0'
      end
    end
    @memory[address] = binary_value.to_i(2)
  end
end

class PartTwoProgram < AbstractProgram
  def execute(address, value)
    binary_address = address.to_s(2).rjust(MASK_LENGTH, '0')
    floating_count = @mask.scan(/X/).count

    @mask.chars.each_with_index do |mask_val, idx|
      case mask_val
      when '1' then binary_address[idx] = '1'
      when 'X' then binary_address[idx] = 'X'
      end
    end

    2.pow(floating_count).times do |version_decimal|
      current_address = binary_address.dup
      version_decimal.to_s(2).rjust(floating_count, '0').chars.each do |version_char|
        current_address[current_address.index('X')] = version_char
      end

      @memory[current_address.to_i(2)] = value
    end
  end
end

AoC.part 1, clear_screen: true do
  example_input = <<~TEST_DATA
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
  TEST_DATA
  Assert.equal 165, PartOneProgram.new(example_input.split("\n")).sum

  PartOneProgram.new(AoC::IO.input_file).sum
end

AoC.part 2 do
  example_input = <<~TEST_DATA
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1
  TEST_DATA
  Assert.equal 208, PartTwoProgram.new(example_input.split("\n")).sum

  PartTwoProgram.new(AoC::IO.input_file).sum
end
