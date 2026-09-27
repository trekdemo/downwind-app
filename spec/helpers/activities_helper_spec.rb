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
      expect(helper.duration_parts(3723)).to eq([ '1:02:03', nil ])
    end
  end

  describe '#number_to_duration' do
    it 'formats zero seconds' do
      expect(helper.number_to_duration(0)).to eq('0:00:00')
    end

    it 'formats seconds only' do
      expect(helper.number_to_duration(45)).to eq('0:00:45')
    end

    it 'formats minutes and seconds' do
      expect(helper.number_to_duration(120)).to eq('0:02:00')
    end

    it 'formats hours, minutes and seconds' do
      expect(helper.number_to_duration(3605)).to eq('1:00:05')
    end

    it 'formats hours and minutes without leftover seconds' do
      expect(helper.number_to_duration(3900)).to eq('1:05:00')
    end

    it 'does not wrap hours past 24' do
      expect(helper.number_to_duration(108_000)).to eq('30:00:00')
    end

    it 'rounds fractional seconds' do
      expect(helper.number_to_duration(45.6)).to eq('0:00:46')
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
