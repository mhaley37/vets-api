# frozen_string_literal: true

require 'rails_helper'
require 'support/rx_client_helpers'
require 'support/shared_examples_for_mhv'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'rx_refill', type: :request do
  include JsonSchemaMatchers
  include Rx::ClientHelpers

  let(:mhv_account_type) { 'Premium' }
  let(:json_body_headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  before do
    allow_any_instance_of(MHVAccountTypeService).to receive(:mhv_account_type).and_return(mhv_account_type)
    allow(Rx::Client).to receive(:new).and_return(authenticated_client)
    current_user = build(:iam_user, :mhv)

    iam_sign_in(current_user)
  end

  describe 'GET /mobile/v0/rx-refill/rx_history' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
        get '/mobile/v0/rx-refill/rx_history', headers: iam_headers
      end
    end

    it 'matches the rx_history schema' do
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /mobile/v0/rx-refill/rx_history/tracking/:id' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/nested_resources/gets_tracking_for_a_prescription') do
        get '/mobile/v0/rx-refill/rx_history/tracking/13650541', headers: iam_headers
      end
    end

    it 'matches the get_single_rx_history schema' do
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /mobile/v0/rx-refill/preferences' do
    before do
      VCR.use_cassette('rx_refill/preferences/gets_rx_preferences') do
        get '/mobile/v0/rx-refill/preferences', headers: iam_headers
      end
    end

    it 'matches the get_preferences schema' do
      attributes = response.parsed_body.dig('data', 'attributes')
      expect(attributes['emailAddress']).to eq('Praneeth.Gaganapally@va.gov')
      expect(attributes['rxFlag']).to eq(true)
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /mobile/v0/rx-refill/preferences' do
    before do
      VCR.use_cassette('rx_refill/preferences/sets_rx_preferences') do
        post '/mobile/v0/rx-refill/preferences',
             params: { rx_flag: false, email_address: 'kamyar.karshenas@va.gov' }.to_json,
             headers: iam_headers(json_body_headers)
      end
    end

    it 'returns valid 204 response' do
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'GET /mobile/v0/rx-refill/prescription/:id' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
        get '/mobile/v0/rx-refill/prescription/13568747', headers: iam_headers
      end
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /mobile/v0/rx-refill/refill/:id' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/refills_a_prescription') do
        post '/mobile/v0/rx-refill/refill/13650545', headers: iam_headers
      end
    end

    it 'returns valid 204 response' do
      expect(response).to have_http_status(:no_content)
    end
  end
end
