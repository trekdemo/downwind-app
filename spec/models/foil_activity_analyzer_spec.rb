require 'rails_helper'

RSpec.describe FoilActivityAnalyzer do
  subject(:analyzer) { FoilActivityAnalyzer.new(fixture('wing-activity.gpx'), 15) }

  shared_context 'with a synthetic track' do
    subject(:analyzer) { FoilActivityAnalyzer.new(gpx_file.path, 15) }

    let(:gpx_file) do
      Tempfile.new([ 'synthetic', '.gpx' ]).tap do |file|
        file.write(gpx_track(segments))
        file.flush
      end
    end

    after { gpx_file.close! }

    # @param segments [Array<Array(Integer, Float)>] seconds and speed (m/s) of each segment
    def gpx_track(segments)
      time = Time.utc(2024, 1, 1, 10)
      lat = 52.0
      points = [ [ time, lat ] ]
      segments.each do |seconds, speed|
        time += seconds
        lat += seconds * speed / 111_195.0
        points << [ time, lat ]
      end

      <<~GPX
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" xmlns="http://www.topografix.com/GPX/1/1"
          xmlns:ns3="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
          <trk><trkseg>
            #{points.map { |t, la| %(<trkpt lat="#{la}" lon="5.0"><time>#{t.iso8601}</time><extensions><ns3:TrackPointExtension><ns3:hr>120</ns3:hr></ns3:TrackPointExtension></extensions></trkpt>) }.join("\n")}
          </trkseg></trk>
        </gpx>
      GPX
    end
  end

  describe '#starts' do
    it 'counts the number of time the average speed is above the lift speed' do
      expect(analyzer.starts).to eq(18)
    end
  end

  describe '#data_frame on_foil' do
    it 'matches the brute-force average speed over every trailing 20 second window' do
      distances = analyzer.data_frame[:distance_m].to_a
      elapsed = analyzer.data_frame[:elapsed_sec].to_a
      expected = distances.each_index.map do |i|
        start = i.downto(0).find { |s| elapsed[s..i].sum >= 20 }
        # Before 20 seconds are recorded, the rider is assumed to have stood still
        speed = start ? distances[start..i].sum / elapsed[start..i].sum : distances[0..i].sum / 20.0

        speed > 15 / 3.6 ? 1 : 0
      end

      expect(analyzer.data_frame[:on_foil].to_a).to eq(expected)
    end
  end

  describe '#data_frame on_foil at the start of the recording' do
    include_context 'with a synthetic track'

    # Riding at 9 m/s from the first second, sampled every second
    let(:segments) { Array.new(30) { [ 1, 9.0 ] } }

    it 'counts the rider on foil once the distance covered beats the lift speed over a full window' do
      # 90 m in 10 seconds averages 4.5 m/s over 20 seconds, above 15 km/h
      expect(analyzer.data_frame[:on_foil].to_a.index(1)).to eq(10)
    end
  end

  describe '#starts with irregular sampling' do
    include_context 'with a synthetic track'

    # Garmin smart recording samples densely while speed changes and sparsely
    # while it is steady, so a window of N points spans a varying amount of time.
    let(:segments) do
      [
        *Array.new(30) { [ 1, 2.0 ] },  # paddling at 2 m/s, sampled every second
        *Array.new(5)  { [ 1, 8.0 ] },  # 5 second above take off speed
        *Array.new(30) { [ 1, 2.0 ] },  # paddle for 30 sec more
        *Array.new(12) { [ 10, 6.0 ] }  # foiling at 6 m/s, sampled every 10 seconds
      ]
    end

    it 'averages speed over the last 20 seconds regardless of the number of points' do
      expect(analyzer.starts).to eq(1)
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
