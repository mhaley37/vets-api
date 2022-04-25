# frozen_string_literal: true

require 'rails_helper'
require 'lighthouse/benefits/client'

RSpec.describe Lighthouse::Benefits::Client do
  # setting the client only once for this test set, as it mimics how it's
  # used in the Sidekiq worker disability_compensation_fast_track_job.rb

  before(:all) do
    @client = Lighthouse::Benefits::Client.new
  end

  describe '#list_claims' do
    let(:jwt) { 'fake_client_assurance_token' }
    let(:jwt_double) { double('JWT Wrapper', token: jwt) }
    let(:bearer_token_object) { double('bearer response', body: { 'access_token' => 'blah' }) }

    context 'valid requests' do
      let(:generic_response) do
        double('lighthouse response', status: 200, body: { 'generic': 'response', 'link': [] }.as_json)
      end

      describe 'when requesting' do
        before do
          allow(@client).to receive(:perform).and_return generic_response
          allow(Lighthouse::Benefits::JwtWrapper).to receive(:new).and_return(jwt_double)
          allow(@client).to receive(:authenticate).and_return bearer_token_object
        end

        it 'authenticates to Lighthouse and retrieves a bearer token' do
          @client.list_claims({})
          expect(@client.instance_variable_get(:@bearer_token)).to eq 'blah'
        end

        it 'sets the headers to include the bearer token' do
          headers = {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Vets.gov Agent',
            'Authorization': 'Bearer blah'
          }

          @client.list_claims({})
          expect(@client.instance_variable_get(:@headers_hash)).to eq headers
        end
      end

      describe 'when the caller requests the Claims resource' do
        around do |example|
          VCR.use_cassette('rrd/lighthouse_claims', &example)
        end

        let(:claims_api_path) { 'services/claims/v1/claims' }
        let(:params_hash) do
          {
            ssn: '796378881',
            first_name: 'JESSE',
            last_name: 'GRAY',
            iso8601_dob: '1954-12-15'
          }
        end

        it 'returns the api response' do
          resp = @client.list_claims(params_hash)
          statuses = resp.body['data'].map { |claim| claim['attributes']['status'] }.uniq
          expect(statuses).to match_array ['Initial review', 'Evidence gathering, review, and decision',
                                           'Claim received', 'Preparation for notification', 'Complete']
        end
      end
    end
  end
end
