# typed: false
# frozen_string_literal: true
require './boilerplate.rb'

def solve(lines)
  lines = lines.map do |line|
    ingredients, allergens = line.match(/(.*) \(contains (.*)\)/).captures
    [ingredients.split(" "), allergens.split(", ")]
  end

  allergen_map = lines.map {|ingredients, allergens| allergens.map {|a| [a, ingredients]}}.flatten(1)
  unknown_mappings = allergen_map.to_h
  known_ingredients = []
  known_allergens = []

  while (allergen_map.any? do |allergen, potential_ingredients|
      next if known_allergens.include?(allergen)

      unknown_mappings[allergen] = ((unknown_mappings[allergen] & potential_ingredients) - known_ingredients)

      if unknown_mappings[allergen].length == 1
        known_ingredients << unknown_mappings[allergen].first
        known_allergens << allergen
        unknown_mappings.delete(allergen)
      end
    end)
  end

  unknown_ingredients = (allergen_map.map(&:last).inject(&:+) - known_ingredients)
  {
    unknown_count: lines.sum {|ingredients, _| (ingredients & unknown_ingredients).length},
    known_ingredients: known_ingredients.zip(known_allergens).to_a.sort_by(&:last).map(&:first).join(","),
  }
end

example = <<~EXAMPLE
  mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
  trh fvjkl sbzzf mxmxvkd (contains dairy)
  sqjhc fvjkl (contains soy)
  sqjhc mxmxvkd sbzzf (contains fish)
EXAMPLE

AoC.part 1, clear_screen: true do
  Assert.equal 5, solve(example.split("\n"))[:unknown_count]
  solve(AoC::IO.input_file)[:unknown_count]
end

AoC.part 2 do
  Assert.equal "mxmxvkd,sqjhc,fvjkl", solve(example.split("\n"))[:known_ingredients]
  solve(AoC::IO.input_file)[:known_ingredients]
end
