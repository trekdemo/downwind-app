require 'rails_helper'

RSpec.describe Activity do
  include ActiveJob::TestHelper

  it { is_expected.to belong_to(:user) }
  it { is_expected.to define_enum_for(:kind) }

  it { is_expected.to have_one_attached(:gpx_file) }
  it { is_expected.to validate_attached_of(:gpx_file) }
  it { is_expected.to validate_content_type_of(:gpx_file).allowing('application/gpx+xml') }

  describe '.create' do
    let(:user) { User.create!(email: 'test@example.com', password: 'hunter69') }
    let(:gpx_file) { fixture('garmin_1_1.gpx') }
    subject(:activity) do
      user.activities.with_attached_gpx_file.create(
        gpx_file:,
        lift_speed_kmh: 10,
        kind: :sup_dw
      )
    end

    it 'captures meta data from GPX file' do
      perform_enqueued_jobs do
        activity # Created the activity
        activity.reload # Load changes done by the GPXAnalyzer
        expect(activity.title).to eq('Example activity title')
        expect(activity.started_at).to eq('2024-02-04T16:43:07.000Z')
      end
    end
  end

  describe '#started_at' do
    it 'falls back to created_at when the GPX had no timestamps' do
      activity = build(:activity, started_at: nil, created_at: Time.zone.parse('2024-03-01 12:00:00'))

      expect(activity.started_at).to eq(activity.created_at)
    end

    it 'returns the GPX-derived value when present' do
      time = Time.zone.parse('2024-03-01 12:00:00')
      activity = build(:activity, started_at: time)

      expect(activity.started_at).to eq(time)
    end
  end

  describe '#analyzed?' do
    let(:user) { User.create!(email: 'test@example.com', password: 'hunter69') }
    let(:gpx_file) { fixture('garmin_1_1.gpx') }
    subject(:result) { activity.analyzed? }

    context 'when the activity is new' do
      let(:activity) { described_class.new }

      it { is_expected.to eq false }
    end

    context 'when the activity is saved but not processed' do
      let(:activity) do
        user.activities.with_attached_gpx_file.create(
          gpx_file:,
          lift_speed_kmh: 10,
          kind: :sup_dw
        )
      end

      it { is_expected.to eq false }
    end

    context 'when the activity is saved and processed' do
      let(:activity) do
        perform_enqueued_jobs do
          user.activities.with_attached_gpx_file.create(
            gpx_file:,
            lift_speed_kmh: 10,
            kind: :sup_dw
          )
        end
      end

      it { is_expected.to eq true }
    end
  end
end
