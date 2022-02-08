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

      it 'absence of menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).not_to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end
    end

    context 'user has both roles for both attestations consultation' do
      let(:user) { user_both_roles }

      it 'presence of menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))

          expect{ click_on(I18n.t('.shared.user_signed_in_side_menu.download_attestations')) }.to change{
            page.current_path
          }.to(user_download_attestations_path)
        end
      end

      context 'attestations download' do
        let(:mardi_24_aout)   { Time.local(2021,8,24,12,0) }
        let(:now) { mardi_24_aout }

        before do
          Timecop.freeze(now)
          visit user_download_attestations_path
        end

        end

        let(:valid_siret) { }
        let(:today) { Time.now } # should use timecop freeze

        it 'proposes to download both attestation fiscale and sociale' do
          expect(page).to have_content(I18n.t('.users.download_attestations.cbx_sociale_text'))
          expect(page).to have_content(I18n.t('.users.download_attestations.cbx_fiscale_text'))

          expect(page).to have_css('input#search_attestations_for_siret'))
        end

        it 'gives the user individual links for a valid_siret having 2 attestations'
          fill_in 'siret', with: valid_siret
          click_on(I18n.t('users.download_attestations.cta_search'))

          # mocking here pls for attestations calls + use turbo

          attestation_fiscale_filename = ['attestation_fiscale', valid_siret, '2021_08_24'].join('_')
          attestation_sociale_filename = ['attestation_sociale', valid_siret, '2021_08_24'].join('_')

          expect(page).to have_css("a[download=attestation_fiscale_filename]")
          expect(page).to have_css("a[download=attestation_sociale_filename")
        end

        it 'displays the token being used' do

        end

        it 'cinematic for attestation fiscale' do

        end

        it 'cinematic for attestation sociale' do

        end
      end
    end

    context 'user has role allowing attestations sociales consultation' do
      let(:user) { user_sociales_only }

      it 'presence of menu item for attestations download' do
        within('.authenticated-user-sidemenu') do
          expect(page).to have_content(I18n.t('.shared.user_signed_in_side_menu.download_attestations'))
        end
      end

      context 'attestations download' do
      end
    end

  end
end
