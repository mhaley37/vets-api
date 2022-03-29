# frozen_string_literal: true

require 'rails_helper'
require 'support/rx_client_helpers'
require 'support/shared_examples_for_mhv'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'rx_refill', type: :request do
  include JsonSchemaMatchers
  include Rx::ClientHelpers

  # let(:va_patient) { true }
  let(:mhv_account_type) { 'Premium' }
  # let(:current_user) do
  #  build(:user, :mhv, authn_context: LOA::IDME_LOA3_VETS, va_patient: va_patient, mhv_account_type: mhv_account_type, sign_in: { service_name: 'idme' })
  # end
  let(:json_body_headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  before do
    allow_any_instance_of(MHVAccountTypeService).to receive(:mhv_account_type).and_return(mhv_account_type)
    allow(Rx::Client).to receive(:new).and_return(authenticated_client)
    current_user = build(:iam_user, :idme)

    iam_sign_in(current_user)
  end

  describe 'GET /mobile/v0/rx-refill/get_full_rx_history' do
    context 'with a valid 200 response' do
      it 'matches the get_full_rx_history schema' do
        VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
          get '/mobile/v0/rx-refill/full_rx_history', headers: iam_headers
        end
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/get_single_rx_history' do
    context 'with a valid 200 response' do
      it 'matches the get_single_rx_history schema' do
        VCR.use_cassette('rx_refill/prescriptions/nested_resources/gets_tracking_for_a_prescription') do
          get '/mobile/v0/rx-refill/get_single_rx_history/13650541', headers: iam_headers
        end
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/get_preferences' do
    context 'with a valid 200 response' do
      it 'matches the get_preferences schema' do
        VCR.use_cassette('rx_refill/preferences/gets_rx_preferences') do
          get '/mobile/v0/rx-refill/get_preferences', headers: iam_headers
        end
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/post_preferences' do
    context 'with a valid 204 response' do
      it 'matches the post_preferences schema' do
        VCR.use_cassette('rx_refill/preferences/sets_rx_preferences') do
          post '/mobile/v0/rx-refill/post_preferences',
               params: { rx_flag: false, email_address: 'kamyar.karshenas@va.gov' }.to_json,
               headers: iam_headers(json_body_headers)
        end
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/get_prescription' do
    context 'with a valid 200 response' do
      it 'matches the get_prescription schema' do
        VCR.use_cassette('rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do
          get '/mobile/v0/rx-refill/get_prescription/13568747', headers: iam_headers
        end
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /mobile/v0/rx-refill/post_refill' do
    context 'with a valid 204 response' do
      it 'matches the post_refill schema' do
        VCR.use_cassette('rx_refill/prescriptions/refills_a_prescription') do
          post '/mobile/v0/rx-refill/post_refill/13650545', headers: iam_headers
        end
        expect(response).to have_http_status(:no_content)
      end
    end
  end

end
