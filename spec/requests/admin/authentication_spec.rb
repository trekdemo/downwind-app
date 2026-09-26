require 'rails_helper'

RSpec.describe "Admin authentication", type: :request do
  context "when signed out" do
    it "redirects to the sign in page" do
      get admin_users_url

      expect(response).to redirect_to(sign_in_url)
    end
  end

  context "when signed in as a non-admin user" do
    it "redirects to the root path" do
      User.create! id: 1, email: 'admin@dw.test', password: 'hunter2'
      user = User.create! email: 'regular@dw.test', password: 'hunter2'
      sign_in_as(user, password: 'hunter2')

      get admin_users_url

      expect(response).to redirect_to(root_path)
    end
  end
end
