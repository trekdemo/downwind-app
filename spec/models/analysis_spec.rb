require 'rails_helper'

RSpec.describe Analysis, type: :model do
  describe '#route_bounds_calculated?' do
    let(:analysis) { create(:analysis) }

    context 'when route_bounds is present' do
      before do
        analysis.update!(route_bounds: {
          north: 40.7128,
          south: 40.7089,
          east: -74.0060,
          west: -74.0118
        })
      end

      it 'returns true' do
        expect(analysis.route_bounds_calculated?).to be true
      end
    end

    context 'when route_bounds is nil' do
      before do
        analysis.update!(route_bounds: nil)
      end

      it 'returns false' do
        expect(analysis.route_bounds_calculated?).to be false
      end
    end

    context 'when route_bounds is empty hash' do
      before do
        analysis.update!(route_bounds: {})
      end

      it 'returns false' do
        expect(analysis.route_bounds_calculated?).to be false
      end
    end

    context 'when route_bounds has only some keys' do
      before do
        analysis.update!(route_bounds: { north: 40.7128 })
      end

      it 'returns false' do
        expect(analysis.route_bounds_calculated?).to be false
      end
    end

    context 'when route_bounds has all required keys' do
      before do
        analysis.update!(route_bounds: {
          north: 40.7128,
          south: 40.7089,
          east: -74.0060,
          west: -74.0118
        })
      end

      it 'returns true' do
        expect(analysis.route_bounds_calculated?).to be true
      end
    end
  end
end
