# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

Noop = Struct.new(:id, :argument) do
  def execute(program); program.instruction += 1; end
  def decorrupt; Jump.new(id, argument); end
end

Add = Struct.new(:id, :amount) do
  def execute(program); program.accumulator += amount; program.instruction += 1; end
  def decorrupt; self; end
end

Jump = Struct.new(:id, :amount) do
  def execute(program); program.instruction += amount; end
  def decorrupt; Noop.new(id, amount); end
end

class Commands
  attr_accessor :accumulator, :instruction

  def initialize(lines)
    @commands = lines.each_with_index.map do |line, id|
      command, argument = line.split(" ")
      case command
      when "nop" then Noop.new(id, argument.to_i)
      when "acc" then Add.new(id, argument.to_i)
      when "jmp" then Jump.new(id, argument.to_i)
      else; raise "unknown command: #{command}"
      end
    end
    reset_run_state
  end

  def run
    while !infinite_loop? && !completed_normally?
      @history.push(@commands[@instruction])
      @history.last.execute(self)
    end

    @accumulator
  end

  def uncorrupt
    @commands.length.times do |index|
      run
      return @accumulator if completed_normally?

      reset_run_state
      @commands[index - 1] = @commands[index - 1].decorrupt unless index == 0
      @commands[index] = @commands[index].decorrupt
    end
  end

  private def reset_run_state
    @accumulator = 0
    @instruction = 0
    @history = []
  end

  private def infinite_loop?
    @history.include?(@commands[@instruction])
  end

  private def completed_normally?
    @instruction == @commands.length
  end
end

TEST_DATA = <<~TEST_DATA
  nop +0
  acc +1
  jmp +4
  acc +3
  jmp -3
  acc -99
  acc +1
  jmp -4
  acc +6
TEST_DATA

AoC.part 1, clear_screen: true do
  Assert.call Commands.new(TEST_DATA.split("\n")), 5, :run
  Commands.new(AoC::IO.input_file).run
end

AoC.part 2 do
  Assert.call Commands.new(TEST_DATA.split("\n")), 8, :uncorrupt
  Commands.new(AoC::IO.input_file).uncorrupt
end
