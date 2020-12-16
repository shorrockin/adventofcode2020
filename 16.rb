# typed: false
# frozen_string_literal: true
require './boilerplate.rb'
require './16_test_data.rb'

ValidationRange = Struct.new(:lower, :upper) do
  def is_valid_number?(number); number >= lower && number <= upper; end
end

Validation = Struct.new(:name, :range_one, :range_two) do
  def is_valid_number?(number); range_one.is_valid_number?(number) || range_two.is_valid_number?(number); end
end

Tickets = Struct.new(:validations, :your_ticket, :nearby_tickets) do
  def is_valid_number?(number)
    validations.any? {|validation| validation.is_valid_number?(number)}
  end
end

def parse(lines)
  validations = []
  your_ticket = nil
  nearby_tickets = []

  lines.each do |line|
    if (match = line.match(/([a-z ]+): ([0-9]+)\-([0-9]+) or ([0-9]+)\-([0-9]+)/))
      name, r1, r2, r3, r4 = match.captures
      validations << Validation.new(name, ValidationRange.new(r1.to_i, r2.to_i), ValidationRange.new(r3.to_i, r4.to_i))
    elsif line.match?(/^[0-9]+,/)
      if your_ticket.nil?
        your_ticket = line.split(',').map(&:to_i)
      else
        nearby_tickets << line.split(',').map(&:to_i)
      end
    end
  end

  Tickets.new(validations, your_ticket, nearby_tickets)
end

example_one = parse(TEST_DATA_ONE.split("\n"))
example_two = parse(TEST_DATA_TWO.split("\n"))
input = parse(AoC::IO.input_file)

AoC.part 1, clear_screen: true do
  Assert.equal 3, example_one.validations.length
  Assert.equal [7, 1, 14], example_one.your_ticket
  Assert.equal [55, 2, 20], example_one.nearby_tickets[2]

  def sum_invalid(tickets)
    tickets.nearby_tickets.map do |numbers|
      numbers.reject {|number| tickets.is_valid_number?(number)}
    end.to_a.flatten.compact.sum
  end

  Assert.equal 71, sum_invalid(example_one)

  sum_invalid(input)
end

AoC.part 2 do
  def solve(tickets, containing)
    valid_tickets = tickets.nearby_tickets.select do |numbers|
      numbers.all? {|n| tickets.is_valid_number?(n)}
    end

    mappings = {}
    while mappings.length != tickets.validations.length
      (tickets.validations - mappings.values).each_with_index.map do |validation|
        field_ids = tickets.validations.length.times.select do |index|
          mappings[index].nil? && valid_tickets.all? {|ticket| validation.is_valid_number?(ticket[index])}
        end

        mappings[field_ids.first] = validation if field_ids.length == 1
      end
    end

    mappings.select {|_, validation| validation.name.include?(containing)}.map do |idx, _|
      tickets.your_ticket[idx]
    end.inject(&:*)
  end

  Assert.equal 156, solve(example_two, "s")
  solve(input, "departure")
end
