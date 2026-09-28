# frozen_string_literal: true

# Reduces a GPS track to a handful of points that still look like the route,
# small enough to store with the analysis and draw as a preview.
#
# Uses Ramer–Douglas–Peucker: every point gets a significance, how far it is
# from the segment that would replace it, and only the most significant ones
# are kept. Distances are measured on an equirectangular projection, so a
# degree of longitude counts less the further the route is from the equator.
class RouteSimplifier
  MAX_POINTS = 125
  # Deviations below this share of the route's diagonal are GPS noise
  TOLERANCE_RATIO = 1 / 500.0
  PRECISION = 5 # decimal places, ~1 m

  # @param points [Array<Array(Float, Float)>] [lat, lon] pairs in track order
  # @param max_points [Integer] upper limit of points in the simplified route
  def initialize(points, max_points: MAX_POINTS)
    @points = points
    @max_points = max_points
  end

  # @return [Array<Array(Float, Float)>] the simplified [lat, lon] pairs
  def simplify
    return @points.map { |point| round(point) } if @points.size <= 2

    kept = significances.each_with_index
      .select { |significance, _| significance > tolerance }
      .max_by(@max_points) { |significance, _| significance }
      .map(&:last)
      .sort

    kept.map { |index| round(@points[index]) }
  end

  private

  # A point's significance is capped just below the one of the point that
  # split its segment, so keeping the top N never keeps a point without its
  # parent.
  # Segments within tolerance are not split further: their points are
  # dropped anyway, and splitting stationary stretches one point at a time
  # would be quadratic.
  #
  # @return [Array<Float>] per point, the deviation at which RDP would keep it
  def significances
    result = Array.new(projected.size, 0.0)
    result[0] = result[-1] = Float::INFINITY

    stack = [ [ 0, projected.size - 1, Float::INFINITY ] ]
    until stack.empty?
      first, last, parent_significance = stack.pop
      index, distance = farthest_point(first, last)
      next if index.nil? || distance <= tolerance

      result[index] = [ distance, parent_significance.prev_float ].min
      stack.push([ first, index, result[index] ], [ index, last, result[index] ])
    end

    result
  end

  # @return [Array(Integer, Float), nil] the index and distance of the point
  #   between first and last that is farthest from the segment joining them
  def farthest_point(first, last)
    index = nil
    max_distance = -1.0

    ((first + 1)...last).each do |i|
      distance = distance_to_segment(projected[i], projected[first], projected[last])
      next unless distance > max_distance

      index = i
      max_distance = distance
    end

    [ index, max_distance ] if index
  end

  def tolerance
    @tolerance ||= begin
      xs, ys = projected.transpose
      Math.hypot(xs.max - xs.min, ys.max - ys.min) * TOLERANCE_RATIO
    end
  end

  # @return [Array<Array(Float, Float)>] [x, y] pairs in degrees of latitude
  def projected
    @projected ||= begin
      lats = @points.map(&:first)
      scale = Math.cos((lats.min + lats.max) / 2.0 * Math::PI / 180)
      @points.map { |lat, lon| [ lon * scale, lat ] }
    end
  end

  def distance_to_segment(point, a, b)
    dx = b[0] - a[0]
    dy = b[1] - a[1]
    length_squared = dx**2 + dy**2
    return Math.hypot(point[0] - a[0], point[1] - a[1]) if length_squared.zero?

    t = (((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / length_squared).clamp(0.0, 1.0)
    Math.hypot(point[0] - (a[0] + t * dx), point[1] - (a[1] + t * dy))
  end

  def round(point) = point.map { |coordinate| coordinate.round(PRECISION) }
end
