require 'rails_helper'

RSpec.describe FoilActivityAnalyzer do
  subject(:analyzer) { FoilActivityAnalyzer.new(fixture('wing-activity.gpx'), 15) }

  describe '#starts' do
    it 'counts the number of time the average speed is above the lift speed' do
      expect(analyzer.starts).to eq(18)
    end
  end

  describe '#speed_avg' do
    it 'counts the number of time the average speed is above the lift speed' do
      expect(analyzer.speed_avg).to eq(4.291928004881026)
    end
  end

  describe '#duration' do
    it 'calculates the duration' do
      expect(analyzer.duration).to eq(3599.0)
    end
  end

  describe '#fastest_full_km' do
    it 'matches the brute-force minimum over every 1 km window' do
      dist = analyzer.data_frame[:distance_cumsum_m].to_a
      times = analyzer.data_frame[:timestamp].to_a
      expected = dist.each_index.filter_map do |i|
        j = dist.index { |d| d > dist[i] + 1_000 }
        times[j] - times[i] if j
      end.min

      expect(analyzer.fastest_full_km).to eq(expected)
    end
  end

  describe '#route_bounds' do
    it 'calculates geographical bounds from trackpoints' do
      bounds = analyzer.route_bounds

      expect(bounds).to be_a(Hash)
      expect(bounds['north']).to be_a(Float)
      expect(bounds['south']).to be_a(Float)
      expect(bounds['east']).to be_a(Float)
      expect(bounds['west']).to be_a(Float)
      expect(bounds['north']).to be > bounds['south']
      expect(bounds['east']).to be > bounds['west']
    end
  end

  describe '#route_preview' do
    it 'simplifies the route to [lat, lon] pairs within the route bounds' do
      preview = analyzer.route_preview
      bounds = analyzer.route_bounds

      expect(preview.size).to be_between(2, RouteSimplifier::MAX_POINTS)
      expect(preview).to all(match([
        be_between(bounds['south'].round(5), bounds['north'].round(5)),
        be_between(bounds['west'].round(5), bounds['east'].round(5))
      ]))
    end
  end
end
