require 'rails_helper'

RSpec.describe "/admin/users", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { email: 'cool-dude@example.com', password: 'hunter2' }
  }

  let(:invalid_attributes) {
    { email: nil, password: nil }
  }

  before do
    # The user with ID=1
    admin = User.create! id: 1, email: 'admin@dw.test', password: 'hunter2'
    sign_in_as(admin, password: 'hunter2')
  end

  describe "GET /index" do
    it "renders a successful response" do
      User.create! valid_attributes
      get admin_users_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_admin_user_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get edit_admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { password: 'hunter3' }
      }

      it "updates the requested user" do
        user = User.create! valid_attributes
        expect {
          patch admin_user_url(user), params: { user: new_attributes }
        }.to change { user.reload.updated_at }
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        patch admin_user_url(user), params: { user: new_attributes }
        user.reload
        expect(response).to redirect_to(admin_user_url(user))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        user = User.create! valid_attributes
        patch admin_user_url(user), params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete admin_user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the admin_users list" do
      user = User.create! valid_attributes
      delete admin_user_url(user)
      expect(response).to redirect_to(admin_users_url)
    end
  end
end
