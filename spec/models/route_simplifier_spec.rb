require 'rails_helper'

RSpec.describe RouteSimplifier do
  describe '#simplify' do
    it 'keeps the first and last points' do
      points = [ [ 47.0, 19.0 ], [ 47.001, 19.001 ], [ 47.002, 19.0 ] ]

      simplified = RouteSimplifier.new(points).simplify

      expect(simplified.first).to eq([ 47.0, 19.0 ])
      expect(simplified.last).to eq([ 47.002, 19.0 ])
    end

    it 'drops points lying on a straight line' do
      points = (0..100).map { |i| [ 47.0 + i * 0.0001, 19.0 + i * 0.0001 ] }

      expect(RouteSimplifier.new(points).simplify).to eq([ [ 47.0, 19.0 ], [ 47.01, 19.01 ] ])
    end

    it 'keeps a sharp corner' do
      leg_out = (0..50).map { |i| [ 47.0, 19.0 + i * 0.0002 ] }
      leg_back = (1..50).map { |i| [ 47.0 + i * 0.0002, 19.01 ] }

      expect(RouteSimplifier.new(leg_out + leg_back).simplify).to include([ 47.0, 19.01 ])
    end

    it 'keeps the far end of a route that returns to its start' do
      out_and_back = (0..50).map { |i| [ 47.0, 19.0 + i * 0.0002 ] }
      out_and_back += out_and_back.reverse

      expect(RouteSimplifier.new(out_and_back).simplify).to include([ 47.0, 19.01 ])
    end

    it 'caps the number of points' do
      zigzag = (0..1_000).map { |i| [ 47.0 + (i.even? ? 0 : 0.001), 19.0 + i * 0.0001 ] }

      expect(RouteSimplifier.new(zigzag, max_points: 50).simplify.size).to eq(50)
    end

    it 'rounds coordinates to 5 decimal places' do
      points = [ [ 47.1234567, 19.7654321 ], [ 47.2, 19.8 ] ]

      expect(RouteSimplifier.new(points).simplify.first).to eq([ 47.12346, 19.76543 ])
    end

    it 'keeps a peak over a deeper dip found later when capping' do
      # RDP picks the peak first; the dip only deviates more from the
      # shorter segment the peak creates, so it must not outrank the peak.
      points = [ [ 0.0, 0.0 ], [ -0.9, 5.0 ], [ 1.0, 5.0 ], [ 0.0, 10.0 ] ]

      expect(RouteSimplifier.new(points, max_points: 3).simplify).to eq([ [ 0.0, 0.0 ], [ 1.0, 5.0 ], [ 0.0, 10.0 ] ])
    end

    it 'reduces a route that never moved to its endpoints' do
      expect(RouteSimplifier.new([ [ 47.0, 19.0 ] ] * 10).simplify).to eq([ [ 47.0, 19.0 ] ] * 2)
    end

    it 'handles a long stationary break quickly' do
      ride_out = (0..500).map { |i| [ 47.0 + Math.sin(i / 20.0) * 0.001, 19.0 + i * 0.0001 ] }
      ride_back = ride_out.reverse.map { |lat, lon| [ lat + 0.002, lon ] }
      points = ride_out + [ ride_out.last ] * 20_000 + ride_back

      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      RouteSimplifier.new(points).simplify
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started

      expect(elapsed).to be < 1
    end

    it 'returns an empty route unchanged' do
      expect(RouteSimplifier.new([]).simplify).to eq([])
    end

    it 'simplifies a real session to at most 125 points' do
      foil = FoilActivityAnalyzer.new(fixture('wing-activity.gpx'), 15)
      points = foil.data_frame[:lat].to_a.zip(foil.data_frame[:lon].to_a)

      expect(RouteSimplifier.new(points).simplify.size).to be_between(20, 125)
    end
  end
end
