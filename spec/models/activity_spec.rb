require 'rails_helper'

RSpec.describe Activity do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to define_enum_for(:kind) }

  it { is_expected.to have_one_attached(:gpx_file) }
  it { is_expected.to validate_attached_of(:gpx_file) }
  it { is_expected.to validate_content_type_of(:gpx_file).allowing('application/gpx+xml') }

  describe '.create' do
    include ActiveJob::TestHelper

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
end
