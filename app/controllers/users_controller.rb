class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
  end

  def download_attestations
    @user = current_user
  end
end
