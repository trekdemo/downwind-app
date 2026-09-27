require 'rails_helper'

RSpec.describe ActivitiesHelper, type: :helper do
  describe '#distance_parts' do
    it 'returns the value and unit as separate strings' do
      expect(helper.distance_parts(12_400)).to eq([ '12.4', 'km' ])
    end

    it 'keeps meters for short distances' do
      expect(helper.distance_parts(500)).to eq([ '500', 'm' ])
    end
  end

  describe '#speed_parts' do
    it 'returns the value and unit as separate strings' do
      expect(helper.speed_parts(15.333)).to eq([ '15.3', 'km/h' ])
    end
  end

  describe '#duration_parts' do
    it 'returns the formatted duration with a nil unit' do
      expect(helper.duration_parts(3723)).to eq([ '01:02:03', nil ])
    end
  end

  describe '#kind_badge' do
    it 'renders the human kind name with a per-kind colour class' do
      badge = helper.kind_badge('sup_dw')

      expect(badge).to include('badge-cyan')
      expect(badge).to include('Downwind SUP')
    end

    it 'accepts an activity and reads its kind' do
      activity = build(:activity, kind: 'wingfoil')

      expect(helper.kind_badge(activity)).to include('badge-teal')
    end
  end
end
