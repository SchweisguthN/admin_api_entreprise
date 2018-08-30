require 'rails_helper'

describe JwtApiEntreprise, type: :jwt do
  let(:jwt) { create(:jwt_api_entreprise) }

  describe '#rehash' do
    let(:token) { jwt.rehash }

    it 'returns a jwt' do
      expect(token).to match(/\A([a-zA-Z0-9_-]+\.){2}([a-zA-Z0-9_-]+)?\z/)
    end

    describe 'generated JWT payload' do
      let(:payload) { extract_payload_from(token) }

      it 'contains its owner user id into the "uid" key' do
        expect(payload.fetch(:uid)).to eq(jwt.user_id)
      end

      it 'contains its id into the "jti" key' do
        expect(payload.fetch(:jti)).to eq(jwt.id)
      end

      it 'contains its subject into the "sub" key' do
        expect(payload.fetch(:sub)).to eq(jwt.subject)
      end

      it 'contains its creation timestamp into the "iat" key' do
        expect(payload.fetch(:iat)).to eq(jwt.iat)
      end

      it 'contains all its access roles into the "roles" key' do
        jwt_roles = jwt.roles.pluck(:code)

        expect(payload.fetch(:roles)).to eq(jwt_roles)
      end

      describe 'expiration date' do
        it 'contains its expiration date into the "exp" key when not nil' do
          expect(payload.fetch(:exp)).to eq(jwt.exp)
        end

        # ex: Watchdoge JWT for ping has no expiration date
        it 'does not set exp field when expiration date is nil' do
          jwt.exp = nil

          expect(payload).to_not have_key(:exp)
        end
      end

      it 'contains the payload version' do
        expect(payload.fetch(:version)).to_not be_nil
        expect(payload.fetch(:version)).to eq(jwt.version)
      end
    end
  end
end
