class Admin::UsersController < AuthenticatedAdminsController
  if Rails.env.development?
    skip_before_action :authenticate_user!
    skip_before_action :authenticate_admin!
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(user_params[:id])
  end

  def update
    @user = User.find(user_params[:id])
    @user.update_attribute(:note, user_update_params[:note])

    redirect_to admin_user_url(@user)
  end

  def user_params
    params.permit(:id)
  end

  def user_update_params
    params.permit(:id, :note)
  end
end
