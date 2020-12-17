# typed: strict
# frozen_string_literal: true
class Conway
  extend T::Sig

  Coordinate = T.type_alias {T::Array[Integer]}

  sig {params(data: T::Array[String], dimensions: Integer, active_char: String).void}
  def initialize(data, dimensions, active_char='#')
    @coordinates = T.let({}, T::Hash[Coordinate, T::Boolean])
    @neighbors = T.let([1, 0, -1]
      .repeated_permutation(dimensions)
      .reject {|v| v == Array.new(dimensions, 0)}, T::Array[Coordinate])

    data.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        position = Array.new(dimensions) {|i| [x, y].fetch(i, 0)}
        @coordinates[position] = true if char == active_char
      end
    end
  end

  sig {params(iterations: Integer).returns(T.self_type)}
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

  sig {params(coordinate: Coordinate).returns([Coordinate, T::Boolean])}
  def calculate_change(coordinate)
    raise "must implement calculate change method"
  end

  sig {returns(T::Array[Coordinate])}
  def active_coordinates
    @coordinates.keys.select {|c| @coordinates[c]}
  end

  sig {params(coordinate: Coordinate).returns(T::Array[Coordinate])}
  def active_neighbors(coordinate)
    neighbors(coordinate).select {|neighbor| @coordinates[neighbor]}
  end

  sig {params(coordinate: Coordinate).returns(T::Array[Coordinate])}
  def neighbors(coordinate)
    @neighbors.map {|n| [n, coordinate].transpose.map(&:sum)}
  end
end
