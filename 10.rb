# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './10_test_data.rb'

AoC.part 1, clear_screen: true do
  # straight forward attempt to count the number of differences of a given count
  # from a sorted list of numbers.
  def find_differences(adapters, difference)
    1 + adapters.length.times.count do |index|
      index != 0 && (adapters[index] - adapters[index - 1]) == difference
    end
  end

  Assert.equal 7, find_differences(TEST_DATA_1, 1)
  Assert.equal 5, find_differences(TEST_DATA_1, 3)
  Assert.equal 22, find_differences(TEST_DATA_2, 1)
  Assert.equal 10, find_differences(TEST_DATA_2, 3)

  input = AoC::IO.input_file.map(&:to_i).sort
  find_differences(input, 1) * find_differences(input, 3)
end


AoC.part 2 do
  # counts the number of possible adapters an adapter at a given index can
  # connect to. assumes that all adapters connect, and all are within 1 and 3 of
  # each other.
  def count_connections(adapters, index)
    return 0 if adapters.length <= index
    return 3 if (index + 3 < adapters.length) && (adapters[index + 3] - adapters[index]) == 3
    return 2 if (index + 2 < adapters.length) && (adapters[index + 2] - adapters[index]) <= 3
    1
  end

  # there are 3 combinations of connection patterns which represent different
  # multipliers.
  def count_combinations(adapters)
    connections = adapters.length.times.map {|index| count_connections(adapters, index)}
    connections.each_with_index.map do |value, index|
      case [connections[index - 1], value, connections[index + 1], connections[index + 2]]
      when [1, 3, 3, 2] then 7
      when [1, 3, 2, 1] then 4
      when [1, 1, 2, 1] then 2
      else; 1
      end
    end.inject(&:*)
  end

  Assert.equal 1, count_connections(TEST_DATA_1, 0)
  Assert.equal 3, count_connections(TEST_DATA_1, 1)
  Assert.equal 2, count_connections(TEST_DATA_1, 2)
  Assert.equal 1, count_connections(TEST_DATA_1, 3)
  Assert.equal 3, count_connections(TEST_DATA_2, 0)

  Assert.equal 8, count_combinations(TEST_DATA_1.unshift(0))
  Assert.equal 19208, count_combinations(TEST_DATA_2.unshift(0))

  input = AoC::IO.input_file.map(&:to_i).unshift(0).sort
  count_combinations(input)
end
