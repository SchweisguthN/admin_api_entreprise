class DatapassWebhook::FindOrCreateUser < ApplicationInteractor
  def call
    context.user = User.find_or_initialize_by_email(user_attributes['email'])
    context.user.assign_attributes(user_attributes_to_assign)

    return if context.user.save

    fail!('User not valid', 'error', context.user.errors.to_h)
  end

  private

  def user_attributes_to_assign
    {
      'first_name' => user_attributes['given_name'],
      'last_name' => user_attributes['family_name'],
      'phone_number' => user_attributes['phone_number'],
      'oauth_api_gouv_id' => user_attributes['uid'],
      'context' => datapass_attributes['siret']
    }
  end

  def user_attributes
    datapass_attributes['team_members'].find do |team_member|
      team_member['type'] == 'demandeur'
    end
  end

  def datapass_attributes
    context.data['pass']
  end
end
