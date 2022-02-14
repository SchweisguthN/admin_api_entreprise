require 'rails_helper'

RSpec.describe 'private metrics', type: :feature do
  let!(:user_with_token)              { create(:user, :with_jwt) }
  let!(:user_with_inactive_token)     { create(:user, :with_jwt) }
  let!(:user_without_token)           { create(:user) }

  before do
    allow_any_instance_of(UsedJwtIdsElasticQuery).to receive(:perform).and_return(
      user_with_inactive_token.jwt_api_entreprise.pluck(:id)
    )

    allow_any_instance_of(NotInProductionJwtIdsElasticQuery).to receive(:perform).and_return(
      user_with_inactive_token.jwt_api_entreprise.pluck(:id)
    )
  end

  it_behaves_like 'admin_restricted_path', '/admin/private_metrics'

  it 'works (dont want to test images generated by chartkick)' do
    admin = create(:user, :admin)
    login_as(admin)

    expect { visit(admin_private_metrics_path) }.not_to raise_error

    expect(page).to have_current_path(admin_private_metrics_path, ignore_query: true)
  end
end
