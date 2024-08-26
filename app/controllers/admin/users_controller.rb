class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: %i[ edit update destroy ]

  # GET /admin/users
  def index
    @users = User.limit(100)
  end

  # GET /admin/users/1
  def show
    @user = User.includes(:activities).find(params[:id])
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # GET /admin/users/1/edit
  def edit
  end

  # PATCH/PUT /admin/users/1
  def update
    if @user.update(user_params)
      redirect_to [ :admin, @user ], notice: "User was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/users/1
  def destroy
    @user.destroy!
    redirect_to admin_users_url, notice: "User was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:password)
    end
end
