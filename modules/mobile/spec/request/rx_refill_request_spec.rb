# frozen_string_literal: true

require 'rails_helper'
require 'support/rx_client_helpers'
require 'support/shared_examples_for_mhv'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'


RSpec.describe 'rx_refill', type: :request do
  include JsonSchemaMatchers
  include Rx::ClientHelpers

  let(:va_patient) { true }
  let(:mhv_account_type) { 'Premium' }
  #let(:current_user) do
  #  build(:user, :mhv, authn_context: LOA::IDME_LOA3_VETS, va_patient: va_patient, mhv_account_type: mhv_account_type, sign_in: { service_name: 'idme' })
  #end

  before do

    allow_any_instance_of(MHVAccountTypeService).to receive(:mhv_account_type).and_return(mhv_account_type)
    allow(Rx::Client).to receive(:new).and_return(authenticated_client)
    current_user = build(:iam_user, :idme)

    iam_sign_in(current_user)

  end


  describe 'GET /mobile/v0/rx-refill/get_full_rx_history' do
    context 'with a valid 200 response' do
      it 'matches the get_full_rx_history schema' do
          VCR.use_cassette('modules/mobile/spec/support/vcr_cassettes/rx_refill/prescriptions/gets_a_list_of_all_prescriptions') do

            get '/mobile/v0/rx-refill/full_rx_history', headers: iam_headers

        end
        puts 'here1'
        puts response.body
        expect(response).to have_http_status(:ok)

        #expect(JSON.parse(response.body)).to eq(expected_response)
        # expect(response.body).to match_json_schema('disability_rating_response')
      end
    end
  end
end
