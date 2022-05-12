class AttestationPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user, _attestation)
    @user = user
  end

  def any?
    any_token_with_attestation_roles?
  end

  private

  def any_token_with_attestation_roles?
    user.token.flat_map { |jwt| jwt.decorate.attestations_roles }.any?
  end
end
