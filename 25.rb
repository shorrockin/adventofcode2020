# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def transform(subject, loop_size)
  loop_size.times.inject(1) {|value, _| ((value * subject) % 20201227).to_i}
end

def solve(key)
  (0..).inject(1) do |value, number|
    return number if value == key
    (value * 7) % 20201227
  end
end

def calculate_encryption_key(card_public_key, door_public_key)
  transform(card_public_key, solve(door_public_key))
end

AoC.part 1, clear_screen: true do
  card_loop_size = 8
  door_loop_size = 11
  card_public_key = transform(7, card_loop_size)
  door_public_key = transform(7, door_loop_size)
  card_encryption_key = transform(door_public_key, card_loop_size)
  door_encryption_key = transform(card_public_key, door_loop_size)

  Assert.equal 5764801, card_public_key
  Assert.equal 17807724, door_public_key
  Assert.equal card_encryption_key, door_encryption_key
  Assert.equal 14897079, calculate_encryption_key(card_public_key, door_public_key)

  calculate_encryption_key(AoC::IO.input_file[0].to_i, AoC::IO.input_file[1].to_i)
end

AoC.part 2 do
  "Nothing To Do"
end
