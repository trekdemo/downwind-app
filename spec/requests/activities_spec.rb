require 'rails_helper'

RSpec.describe "/activities", type: :request do
  let(:user) { create(:user, password: 'hunter2') }

  before { sign_in_as(user, password: 'hunter2') }

  describe "POST /activities" do
    context "with a valid GPX file" do
      let(:params) do
        { activity: {
          gpx_file: fixture_file_upload(fixture('wing-activity.gpx'), 'application/gpx+xml'),
          lift_speed_kmh: 5,
          kind: 'wingfoil'
        } }
      end

      it "creates the activity and redirects to it" do
        expect { post activities_url, params: params }
          .to change(Activity, :count).by(1)

        expect(response).to redirect_to(Activity.last)
      end
    end

    context "without a GPX file" do
      let(:params) { { activity: { lift_speed_kmh: 5, kind: 'sup_dw' } } }

      it "does not create an activity and re-renders the form" do
        expect { post activities_url, params: params }
          .not_to change(Activity, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("GPX file can&#39;t be blank")
      end
    end

    context "with a file that is not a GPX file" do
      let(:params) do
        { activity: {
          gpx_file: Rack::Test::UploadedFile.new(StringIO.new("hello"), 'text/plain', original_filename: 'notes.txt'),
          lift_speed_kmh: 5,
          kind: 'sup_dw'
        } }
      end

      it "does not create an activity and re-renders the form" do
        expect { post activities_url, params: params }
          .not_to change(Activity, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("GPX file has an invalid content type")
      end
    end
  end
end
