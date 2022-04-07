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

  describe 'GET /mobile/v0/rx-refill/prescriptions' do
    context 'with a valid evss response and no failed facilities' do
      before do
        VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
          get '/mobile/v0/rx-refill/rx-history', headers: iam_headers
        end
      end

      it 'returns expected response' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_json_schema('rx_history')
      end
    end

    context 'with a valid evss response and failed facility' do
      before do
        VCR.use_cassette('rx_refill/prescriptions/handles_failed_stations') do
          get '/mobile/v0/rx-refill/rx-history', headers: iam_headers
        end
      end

      it 'returns expected response' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_json_schema('rx_history')
      end
    end

    context 'with an 403 forbidden response' do
      before do
        unauthorized_user = build(:iam_user)
        iam_sign_in(unauthorized_user)

        VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
          get '/mobile/v0/rx-refill/rx-history', headers: iam_headers
        end
      end

      it 'returns expected error response' do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to eq({ 'errors' =>
                                              [{ 'title' => 'Forbidden',
                                                 'detail' => 'User does not have access to the requested resource',
                                                 'code' => '403',
                                                 'status' => '403' }] })
      end
    end
  end
end
