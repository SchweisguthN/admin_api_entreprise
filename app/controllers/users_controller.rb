class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user

    @can_download_attestations = any_token_with_attestation_role?
  end

  def download_attestations
    @user = current_user

    @can_download_attestations = any_token_with_attestation_role?
  end

  def any_token_with_attestation_role?
    (tokens_roles_codes & attestations_roles_codes).any?
  end

  def tokens
    @tokens = current_user.jwt_api_entreprise.relevant
  end

  def tokens_roles_codes
    @tokens_roles_codes ||= tokens.joins(:roles).pluck('roles.code').uniq
  end

  def attestations_roles_codes
    %w(attestations_sociales attestations_fiscales)
  end
end
