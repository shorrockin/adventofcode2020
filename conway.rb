# typed: false
# frozen_string_literal: true

class Conway
  def initialize(data, dimensions, active_char='#')
    @coordinates = {}
    @neighbors = [1, 0, -1]
      .repeated_permutation(dimensions)
      .reject {|v| v == Array.new(dimensions, 0)}

    data.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        position = Array.new(dimensions) {|i| [x, y].fetch(i, 0)}
        @coordinates[position] = true if char == active_char
      end
    end
  end

  def cycle(iterations=6)
    iterations.times do
      @coordinates.merge!(
        active_coordinates
        .map {|c| neighbors(c) << c}
        .flatten(1)
        .uniq
        .map {|c| calculate_change(c)}
        .compact
        .to_h
      )
    end
    self
  end

  def calculate_change(coordinate)
    raise "must implement calculate change method"
  end

  def active_coordinates
    @coordinates.keys.select {|c| @coordinates[c]}
  end

  def active_neighbors(coordinate)
    neighbors(coordinate).select {|neighbor| @coordinates[neighbor]}
  end

  def neighbors(coordinate)
    @neighbors.map {|n| [n, coordinate].transpose.map(&:sum)}
  end
end
