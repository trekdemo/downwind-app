require 'rails_helper'

RSpec.feature "User uploads an activity", type: :feature do
  include ActiveJob::TestHelper

  scenario "when provided information is valid" do
    sign_in
    visit new_activity_path

    expect do
      perform_enqueued_jobs do
        within("#new_activity") do
          attach_file 'GPX file', fixture('wing-activity.gpx')
          fill_in 'Lift speed (km/h)', with: '5'
          choose 'Downwind SUP' # radio button
          click_on 'Create Activity'
        end
      end
    end.to change(Activity, :count).by(1)

    expect(page).to have_content('Downwinger Werkhaven-Vluchhaven')
  end
end
