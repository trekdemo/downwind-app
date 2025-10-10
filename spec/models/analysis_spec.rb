require 'rails_helper'

RSpec.describe Analysis, type: :model do
  describe '#route_center' do
    subject(:analysis) { described_class.new(route_bounds: { north: 0, south: 10, west: -5, east: 5 }) }

    it 'calculates center coordinates from route bounds' do
      center = analysis.route_center

      expect(center).to be_a(Hash)
      expect(center['lat']).to be_a(Float)
      expect(center['lng']).to be_a(Float)

      expect(center['lat']).to eq(5)
      expect(center['lng']).to eq(0)
    end
  end
end
