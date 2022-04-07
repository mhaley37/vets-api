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
    current_user = build(:iam_user,:mhv)

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
        expect(response.parsed_body).to eq({"errors"=>
                                              [{"title"=>"Forbidden",
                                                "detail"=>"User does not have access to the requested resource",
                                                "code"=>"403",
                                                "status"=>"403"}]
                                           }
                                        )
      end
    end



  end

  describe 'GET /mobile/v0/rx-refill/prescriptions/:id/tracking' do
    context 'shipment having other prescriptions' do
      before do
        VCR.use_cassette('rx_refill/prescriptions/nested_resources/gets_a_list_of_tracking_history_for_a_prescription') do
          get '/mobile/v0/rx-refill/prescriptions/13650541/tracking', headers: iam_headers
        end
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_a(String)
        # expect(response).to match_response_schema('trackings')
      end
    end

    context 'shipment having no other prescriptions' do
      before do
        VCR.use_cassette('rx_refill/prescriptions/nested_resources/gets_tracking_with_empty_other_prescriptions') do
          get '/mobile/v0/rx-refill/prescriptions/13650541/tracking', headers: iam_headers
        end
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to be_a(String)
        #expect(response).to match_response_schema('trackings')
      end
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
    context 'With valid parameters' do
      let!(:params) do
        { rx_flag: false, email_address: 'kamyar.karshenas@va.gov' }
      end

      before do
        VCR.use_cassette('rx_refill/preferences/sets_rx_preferences') do
          post '/mobile/v0/rx-refill/preferences',
               params: params.to_json,
               headers: iam_headers(json_body_headers)
        end
      end

      it 'returns valid 200 response' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'With missing parameters' do
      let!(:params) { { rx_flag: false } }

      before do
        VCR.use_cassette('rx_refill/preferences/sets_rx_preferences') do
          post '/mobile/v0/rx-refill/preferences',
               params: params.to_json,
               headers: iam_headers(json_body_headers)
        end
      end

      it 'requires all parameters for update' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'With an email parameter that has a space in it' do
      let!(:params) { { rx_flag: false, email_address: 'kamyar karshenas@va.gov' } }

      before do
        VCR.use_cassette('rx_refill/preferences/raises_a_backend_service_exception_when_email_includes_spaces') do
          post '/mobile/v0/rx-refill/preferences',
               params: params.to_json,
               headers: iam_headers(json_body_headers)
        end
      end

      it 'returns a custom exception mapped from i18n when email contains spaces' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first['code']).to eq('RX157')
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/prescriptions/:id' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
        get '/mobile/v0/rx-refill/prescriptions/13568747', headers: iam_headers
      end
    end

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /mobile/v0/rx-refill/prescriptions/:id/refill' do
    before do
      VCR.use_cassette('rx_refill/prescriptions/refills_a_prescription') do
        post '/mobile/v0/rx-refill/prescriptions/13650545/refill', headers: iam_headers
      end
    end

    it 'returns valid 204 response' do
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end
