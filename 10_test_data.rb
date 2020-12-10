# typed: false
# frozen_string_literal: true

# stored these separately to reduce clutter in 10.rb

def parse_test_data(input)
  input.split("\n").map(&:to_i).sort
end

TEST_DATA_1 = parse_test_data <<~TEST_DATA
  16
  10
  15
  5
  1
  11
  7
  19
  6
  12
  4
TEST_DATA

TEST_DATA_2 = parse_test_data <<~TEST_DATA
  28
  33
  18
  42
  31
  14
  46
  20
  48
  47
  24
  23
  49
  45
  19
  38
  39
  11
  1
  32
  25
  35
  8
  17
  7
  9
  4
  2
  34
  10
  3
TEST_DATA
