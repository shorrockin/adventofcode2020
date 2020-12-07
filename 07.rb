# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

class Solution
  extend T::Sig

  class Bag < T::Struct
    const :name, String
    const :contains, T::Hash[String, Integer]
  end

  sig {params(lines: String).void}
  def initialize(lines)
    @bags = lines.split("\n").map do |line|
      name = line[0...line.index(' bags')]
      contains = line.scan(/([0-9]+) ([a-z ]+) bag/).map {|count, bag| [bag, count.to_i]}
      [name, Bag.new(name: name, contains: contains.to_h)]
    end.to_h
  end

  sig {params(bag_name: String).returns(T::Array[String])}
  def bags_containing(bag_name)
    contains = @bags.select {|_, bag| bag.contains.key?(bag_name)}.keys
    contains += contains.map {|recursive| bags_containing(recursive)}
    contains.flatten.uniq.sort
  end

  sig {params(bag_name: String).returns(Integer)}
  def bag_counts(bag_name)
    @bags[bag_name].contains.sum {|name, count| count + (count * bag_counts(name))}
  end
end

PART_ONE_TEST_DATA = <<~TEST_DATA
  light red bags contain 1 bright white bag, 2 muted yellow bags.
  dark orange bags contain 3 bright white bags, 4 muted yellow bags.
  bright white bags contain 1 shiny gold bag.
  muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
  shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
  dark olive bags contain 3 faded blue bags, 4 dotted black bags.
  vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
  faded blue bags contain no other bags.
  dotted black bags contain no other bags.
TEST_DATA

PART_TWO_TEST_DATA = <<~TEST_DATA
  shiny gold bags contain 2 dark red bags.
  dark red bags contain 2 dark orange bags.
  dark orange bags contain 2 dark yellow bags.
  dark yellow bags contain 2 dark green bags.
  dark green bags contain 2 dark blue bags.
  dark blue bags contain 2 dark violet bags.
  dark violet bags contain no other bags.
TEST_DATA

ACTUAL_DATA = ARGF.read

AoC.part 1, clear_screen: true do
  Assert.call Solution.new(PART_ONE_TEST_DATA), ['bright white', 'dark orange', 'light red', 'muted yellow'], :bags_containing, 'shiny gold'
  Solution.new(ACTUAL_DATA).bags_containing('shiny gold').length
end

AoC.part 2 do
  Assert.call Solution.new(PART_ONE_TEST_DATA), 32, :bag_counts, 'shiny gold'
  Assert.call Solution.new(PART_TWO_TEST_DATA), 126, :bag_counts, 'shiny gold'
  Solution.new(ACTUAL_DATA).bag_counts('shiny gold')
end
