require 'rails_helper'

RSpec.describe "/dashboard", type: :request do
  let(:user) { create(:user, password: 'hunter2') }

  before { sign_in_as(user, password: 'hunter2') }

  # The labels of the progress chart, which is the canvas without a type
  def progress_chart_labels
    canvas = Nokogiri::HTML(response.body).at_css('canvas[data-controller="chart"]:not([data-chart-type-value])')
    JSON.parse(canvas["data-chart-data-value"])["labels"]
  end

  describe "GET /dashboard" do
    let!(:downwind) { create(:activity, :with_analysis, user: user, kind: 'sup_dw', title: 'Downwind session', started_at: 2.days.ago) }
    let!(:wingfoil) { create(:activity, :with_analysis, user: user, kind: 'wingfoil', title: 'Wingfoil session', started_at: 1.day.ago) }

    it "is the root page" do
      get root_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="chart"')
    end

    it "shows the stats and the progress chart, marking the All filter active" do
      get dashboard_url

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Total distance")
      expect(response.body).to include('data-controller="chart"')
      expect(response.body).to match(%r{<a[^>]*aria-current="page"[^>]*>All</a>})
    end

    it "filters by kind, linking the pills back to the dashboard" do
      get dashboard_url(kind: 'wingfoil')

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/aria-current="page"[^>]*>#{Activity.human_attribute_name('kind.wingfoil')}</)
      expect(response.body).to include(%(href="#{dashboard_path(kind: 'sup_dw')}"))
      expect(progress_chart_labels).to eq([ I18n.l(wingfoil.started_at, format: "%b %-d") ])
    end

    it "orders chart labels by activity date, oldest to newest" do
      get dashboard_url

      expect(progress_chart_labels).to eq([ downwind, wingfoil ].map { |activity| I18n.l(activity.started_at, format: "%b %-d") })
    end

    context "with two analyzed sessions on the same day" do
      # Keep these in the same year as downwind/wingfoil above, so this
      # example only exercises the same-day disambiguation, not the
      # cross-year one.
      let(:same_day) { 3.days.ago.to_date }
      let!(:morning) { create(:activity, :with_analysis, user: user, kind: 'sup_dw', title: 'Morning session', started_at: same_day.in_time_zone.change(hour: 8)) }
      let!(:evening) { create(:activity, :with_analysis, user: user, kind: 'sup_dw', title: 'Evening session', started_at: same_day.in_time_zone.change(hour: 18, min: 30)) }

      it "disambiguates same-day chart labels with the time" do
        get dashboard_url

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.l(morning.started_at, format: "%b %-d %H:%M"))
        expect(response.body).to include(I18n.l(evening.started_at, format: "%b %-d %H:%M"))
      end
    end

    context "with an analyzed activity whose GPX had no timestamps" do
      let!(:timeless_activity) { create(:activity, :with_analysis, user: user, kind: 'sup_dw', title: 'Timeless session', started_at: nil) }

      it "returns 200" do
        get dashboard_url

        expect(response).to have_http_status(:ok)
      end
    end

    context "with no activities" do
      it "shows the empty state with an upload CTA" do
        wingfoil.destroy!
        downwind.destroy!

        get dashboard_url

        expect(response.body).to include("No activities yet")
        expect(response.body).to include("Upload your first GPX")
      end
    end
  end
end
