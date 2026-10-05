require 'rails_helper'

RSpec.describe "/admin/design_components", type: :request do
  before do
    admin = User.create! id: 1, email: 'admin@dw.test', password: 'hunter2'
    sign_in_as(admin, password: 'hunter2')
  end

  describe "GET /index" do
    it "renders every component section" do
      get admin_design_components_url

      expect(response).to be_successful
      expect(response.body).to include("Design components", "Colors", "Buttons", "Cards", "Forms", "Tables")
    end
  end
end
