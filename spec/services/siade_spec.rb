require 'rails_helper'

RSpec.describe Siade, type: :service do
  include_context 'with siade payloads'

  let(:token_rehash) { 'dummy token rehash' }
  let(:siade_url) { Rails.application.credentials.siade_url }
  let(:siade_params) do
    {
      context: 'Admin API Entreprise',
      recipient: '13002526500013',
      object: 'Admin API Entreprise request from Attestations Downloader'
    }
  end
  let(:siade_headers) { { Authorization: 'Bearer dummy token rehash' } }
  let(:siret) { siret_valid }
  let(:siren) { siren_valid }

  describe '#entreprise', type: :request do
    subject { described_class.new(token_rehash: token_rehash).entreprises(siret: siret) }

    let(:endpoint_url) { "#{siade_url}v2/entreprises/#{siret}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_entreprise.to_json)
      end

      it 'returns correct result' do
        expect(subject['entreprise']['raison_sociale']).to eq('dummy name')
      end
    end

    context 'when it is not found (404)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 404)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(SiadeClientError).with_message('404 Not Found')
      end
    end
  end

  describe '#attestations_sociales', type: :request do
    subject { described_class.new(token_rehash: token_rehash).attestations_sociales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_sociales_acoss/#{siren}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_sociale.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('http://entreprise.api.gouv.fr/uploads/attestation_sociale.pdf')
      end
    end

    context 'when token is unauthorized (401)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 401)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(SiadeClientError).with_message('401 Unauthorized')
      end
    end
  end

  describe '#attestations_fiscales', type: :request do
    subject { described_class.new(token_rehash: token_rehash).attestations_fiscales(siren: siren) }

    let(:endpoint_url) { "#{siade_url}v2/attestations_fiscales_dgfip/#{siren}" }

    describe 'happy path' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 200, body: payload_attestation_fiscale.to_json)
      end

      it 'returns correct result' do
        expect(subject['url']).to eq('http://entreprise.api.gouv.fr/uploads/attestation_fiscale.pdf')
      end
    end

    context 'with invalid params (422)' do
      before do
        stub_request(:get, endpoint_url)
          .with(query: siade_params, headers: siade_headers)
          .to_return(status: 422)
      end

      it 'raises SiadeClientError' do
        expect { subject }.to raise_error(SiadeClientError).with_message('422 Unprocessable Entity')
      end
    end
  end
end
