require 'rails_helper'

RSpec.describe Activity do
  describe '.new' do
    subject(:activity) { Activity.new(title: 'Title') }

    it 'stores title' do
      expect(activity.title).to eq('Title')
    end

    it 'has an empty list of trackpoints' do
      expect(activity.trackpoints).to be_empty
    end
  end

  describe '.from_gpx' do
    subject(:activity) { Activity.from_gpx(fixture('garmin_1_1.gpx')) }

    it 'captures the title' do
      expect(activity.title).to eq('Example activity title')
    end

    it 'captures the trackpoints' do
      expect(activity.trackpoints).to all(be_a(Hash))
      expect(activity.trackpoints.size).to eq(2)
      expect(activity.trackpoints).to eq(
        [
          {
            timestamp: Time.parse('2024-02-04T16:43:07.000Z'),
            lat: 51.9981014169752597808837890625,
            lon: 5.09016073308885097503662109375,
            hr: 118,
            ellapsed_sec: 0.0,
            distance_m: 0.0,
            speed_m_s: 0.0
          },
          {
            timestamp: Time.parse('2024-02-04T16:43:10.000Z'),
            lat: 51.998198231852054595947265625,
            lon: 5.0901719903743267059326171875,
            hr: 117,
            ellapsed_sec: 3.0,
            distance_m: 10.792874589319885,
            speed_m_s: 3.6
          }
        ]
      )
    end
  end
end
