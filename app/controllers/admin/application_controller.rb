class Admin::ApplicationController < ApplicationController
  before_action :only_me
  layout "application"

  private

  def only_me
    # TECH-DEBT: When needed, replace this check with something more robust
    unless current_user.id == 1
      flash[:error] = "You must be admin to access this section"
      redirect_to root_path
    end
  end
end
