class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)

    @roles = @tokens.joins(:roles).pluck('roles.code').uniq

    @can_download_attestations = (@roles & %w(attestations_sociales attestations_fiscales)).any?
  end

  def download_attestations
    @user = current_user
  end
end
