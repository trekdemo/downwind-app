require 'rails_helper'

RSpec.describe "/activities", type: :request do
  let(:user) { create(:user, password: 'hunter2') }

  before { sign_in_as(user, password: 'hunter2') }

  describe "GET /activities" do
    let!(:downwind) do
      activity = create(:activity, user: user, kind: 'sup_dw', title: 'Downwind session', started_at: 2.days.ago)
      create(:analysis, activity: activity)
      activity
    end
    let!(:wingfoil) do
      activity = create(:activity, user: user, kind: 'wingfoil', title: 'Wingfoil session', started_at: 1.day.ago)
      create(:analysis, activity: activity)
      activity
    end

    it "lists the user's activities and marks the All filter active" do
      get activities_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(downwind.title)
      expect(response.body).to include(wingfoil.title)
      expect(response.body).to match(%r{<a[^>]*aria-current="page"[^>]*>All</a>})
    end

    it "filters activities by kind and marks that pill active" do
      get activities_url(kind: 'wingfoil')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(wingfoil.title)
      expect(response.body).not_to include(downwind.title)
      expect(response.body).to match(/aria-current="page"[^>]*>#{Activity.human_attribute_name('kind.wingfoil')}</)
    end

    it "orders chart labels by activity date, oldest to newest" do
      get activities_url

      oldest_label = I18n.l(downwind.started_at, format: "%b %-d")
      newest_label = I18n.l(wingfoil.started_at, format: "%b %-d")
      body = response.body
      expect(body.index(oldest_label)).to be < body.index(newest_label)
    end

    context "with two analyzed sessions on the same day" do
      # Keep these in the same year as downwind/wingfoil above, so this
      # example only exercises the same-day disambiguation, not the
      # cross-year one.
      let(:same_day) { 3.days.ago.to_date }
      let!(:morning) do
        activity = create(:activity, user: user, kind: 'sup_dw', title: 'Morning session', started_at: same_day.in_time_zone.change(hour: 8))
        create(:analysis, activity: activity)
        activity
      end
      let!(:evening) do
        activity = create(:activity, user: user, kind: 'sup_dw', title: 'Evening session', started_at: same_day.in_time_zone.change(hour: 18, min: 30))
        create(:analysis, activity: activity)
        activity
      end

      it "disambiguates same-day chart labels with the time" do
        get activities_url

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.l(morning.started_at, format: "%b %-d %H:%M"))
        expect(response.body).to include(I18n.l(evening.started_at, format: "%b %-d %H:%M"))
      end
    end

    context "with an un-analyzed activity that has no started_at yet" do
      let!(:pending_activity) do
        create(:activity, user: user, kind: 'sup_dw', title: 'Pending session', started_at: nil)
      end

      it "returns 200" do
        get activities_url

        expect(response).to have_http_status(:ok)
      end
    end

    context "with an analyzed activity whose GPX had no timestamps" do
      let!(:timeless_activity) do
        activity = create(:activity, user: user, kind: 'sup_dw', title: 'Timeless session', started_at: nil)
        create(:analysis, activity: activity)
        activity
      end

      it "returns 200" do
        get activities_url

        expect(response).to have_http_status(:ok)
      end
    end

    it "subscribes to a single per-user turbo stream instead of one per card" do
      get activities_url

      expect(response.body.scan("<turbo-cable-stream-source").size).to eq(1)
    end

    it "draws a route preview on cards that have one" do
      downwind.analysis.update!(route_preview: build(:analysis, :with_route_preview).route_preview)

      get activities_url

      expect(response.body.scan("<polyline").size).to eq(1)
    end

    context "with no activities" do
      it "shows the empty state with an upload CTA" do
        wingfoil.destroy!
        downwind.destroy!

        get activities_url

        expect(response.body).to include("No activities yet")
        expect(response.body).to include("Upload your first GPX")
      end
    end
  end

  describe "GET /activities/:id" do
    context "when the activity has been analyzed" do
      let(:activity) { create(:activity, user: user, kind: 'sup_dw', title: 'Downwind session') }

      before do
        create(:analysis, activity: activity, route_bounds: { "north" => 1, "south" => 0, "east" => 1, "west" => 0 })
      end

      it "renders the activity detail page" do
        get activity_url(activity)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(activity.title)
      end

      it "draws the route preview behind the map" do
        activity.analysis.update!(route_preview: build(:analysis, :with_route_preview).route_preview)

        get activity_url(activity)

        expect(response.body).to match(%r{<svg[^>]*>\s*<polyline})
      end
    end

    context "when the activity has not been analyzed yet" do
      let(:activity) { create(:activity, user: user, kind: 'sup_dw') }

      it "renders the analyzing state without touching analysis data" do
        get activity_url(activity)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Analyzing your session")
      end
    end

    context "when the activity has not been analyzed yet and has no started_at" do
      let(:activity) { create(:activity, user: user, kind: 'sup_dw', started_at: nil) }

      it "renders successfully, falling back to created_at" do
        get activity_url(activity)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Analyzing your session")
      end
    end
  end

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
