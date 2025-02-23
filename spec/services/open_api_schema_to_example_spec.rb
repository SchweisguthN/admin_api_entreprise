require 'rails_helper'

RSpec.describe OpenAPISchemaToExample, type: :service do
  describe '#perform' do
    subject { described_class.new(schema).perform }

    let(:endpoint) { Endpoint.find(example_uid) }
    let(:schema) { endpoint.send(:response_schema) }

    it { is_expected.to eq(JSON.parse(File.read(Rails.root.join('spec/fixtures/insee_unite_legale_example.json')))) }
  end
end
