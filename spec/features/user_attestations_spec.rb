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

    it 'has a menu item for attestations download' do
      within('.authenticated-user-sidemenu') do
        expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
      end
    end
  end
end

