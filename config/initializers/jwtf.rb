JWTF.configure do |config|
  config.algorithm = Rails.application.secrets.jwt_hash_algo
  config.secret = Rails.application.secrets.jwt_hash_secret

  config.token_payload do |resource_owner_id:, **|
    user = User.find(resource_owner_id)

    payload = { uid: resource_owner_id }
    payload[:grants] = []
    payload[:grants].push('token') if user.manage_token?
    payload[:admin] = true if resource_owner_id == Rails.application.secrets.fetch(:admin_uid)
    payload
  end

  config.use_iat_claim = true
  config.exp_period = { hours: 4 }
end
