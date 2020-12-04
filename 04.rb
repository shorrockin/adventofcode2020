# typed: true
# frozen_string_literal: true
require './boilerplate.rb'

class Passport
  extend T::Sig

  REQUIRED = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid']
  attr_accessor :fields

  sig {params(raw_fields: String).void}
  def initialize(raw_fields)
    @fields = raw_fields.scan(/\S+:\S+/).map {|f| T.unsafe(f).split(":")}.to_h
  end

  sig {params(data: String).returns(T::Array[Passport])}
  def self.parse(data)
    data.split("\n\n").map {|raw| Passport.new(raw)}
  end

  sig {returns(T::Boolean)}
  def has_required?
    REQUIRED.count {|r| !fields[r].nil?} == REQUIRED.length
  end

  sig {returns(T::Boolean)}
  def valid?
    REQUIRED.count {|r| !fields[r].nil? && Passport.valid_field?(r, T.must(fields[r]))} == REQUIRED.length
  end

  sig {params(key: String, value: String).returns(T::Boolean)}
  def self.valid_field?(key, value)
    case key
    when "byr" then (value.match?(/^\d{4}$/) && value.to_i >= 1920 && value.to_i <= 2002)
    when "iyr" then (value.match?(/^\d{4}$/) && value.to_i >= 2010 && value.to_i <= 2020)
    when "eyr" then (value.match?(/^\d{4}$/) && value.to_i >= 2020 && value.to_i <= 2030)
    when "hgt" then (value.match?(/^\d{3}cm$/) && value.to_i >= 150 && value.to_i <= 193) || (value.match?(/^\d{2}in$/) && value.to_i >= 59 && value.to_i <= 76)
    when "hcl" then value.match?(/^#[0-9a-f]{6}$/)
    when "ecl" then value.match?(/^((amb|blu|brn|gry|grn|hzl|oth))$/)
    when "pid" then value.match?(/^[0-9]{9}$/)
    when "cid" then true
    else
      raise "invalid key: #{key}"
    end
  end
end

AoC.part 1, clear_screen: true do
  test_data = Passport.parse <<-TEST_DATA
    ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
    byr:1937 iyr:2017 cid:147 hgt:183cm

    iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
    hcl:#cfa07d byr:1929

    hcl:#ae17e1 iyr:2013
    eyr:2024
    ecl:brn pid:760753108 byr:1931
    hgt:179cm

    hcl:#cfa07d eyr:2025 pid:166559648
    iyr:2011 ecl:brn hgt:59in
  TEST_DATA

  Assert.equal 4, test_data.length, "number of parsed test_data passports"
  Assert.equal 8, T.must(test_data[0]).fields.length, "test_data passport count"
  Assert.equal 2, test_data.count(&:has_required?), "test_data valid passport count"

  Passport.parse(AoC::IO.input_file.join("\n")).count(&:has_required?)
end

AoC.part 2 do
  Assert.call Passport, true, :valid_field?, "byr", "2002"
  Assert.call Passport, false, :valid_field?, "byr", "2003"
  Assert.call Passport, false, :valid_field?, "byr", "abrc"
  Assert.call Passport, true, :valid_field?, "hgt", "60in"
  Assert.call Passport, true, :valid_field?, "hgt", "190cm"
  Assert.call Passport, false, :valid_field?, "hgt", "190in"
  Assert.call Passport, false, :valid_field?, "hgt", "190"
  Assert.call Passport, true, :valid_field?, "hcl", "#123abc"
  Assert.call Passport, false, :valid_field?, "hcl", "#123abz"
  Assert.call Passport, false, :valid_field?, "hcl", "123abz"
  Assert.call Passport, true, :valid_field?, "ecl", "brn"
  Assert.call Passport, false, :valid_field?, "ecl", "wat"
  Assert.call Passport, true, :valid_field?, "pid", "000000001"
  Assert.call Passport, false, :valid_field?, "pid", "0123456789"

  Passport.parse(AoC::IO.input_file.join("\n")).count(&:valid?)
end
