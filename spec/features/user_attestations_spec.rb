require 'rails_helper'

RSpec.describe 'User can download attestations', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  subject(:jwt_index) { visit user_tokens_path }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      jwt_index

      expect(page.current_path).to eq(login_path)
    end
  end

  context 'when the user is authenticated' do
    before do
      login_as(user)
      visit user_profile_path
    end

    let(:jwt) { user.jwt_api_entreprise.take }

    let(:role_attestations_sociales) { create(:role, code: 'attestations_sociales') }
    let(:role_attestations_fiscales) { create(:role, code: 'attestations_fiscales') }

    let(:user_no_roles) { create(:user, :with_jwt) }

    let(:user_both_roles) do
      create(:user).tap do |u|
        create(:jwt_api_entreprise, roles: [ role_attestations_sociales, role_attestations_fiscales ], user: u)
      end
    end

    let(:user_sociales_only) do
      create(:user).tap do |u|
        create(:jwt_api_entreprise, roles: [ role_attestations_sociales], user: u)
      end
    end

    context 'user has no roles allowing attestations consultation' do
      let(:user) { user_no_roles }

      it 'does NOT have a menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).not_to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end

    context 'user has both roles for both attestations consultation' do
      let(:user) { user_both_roles }

      it 'does have a menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end

    context 'user has role allowing attestations sociales consultation' do
      let(:user) { user_sociales_only }

      it 'does have a menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end

  end
end
