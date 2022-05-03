# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'Veterens Affairs Eligibility', type: :request do
  include JsonSchemaMatchers

  let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  before do
    allow_any_instance_of(IAMUser).to receive(:icn).and_return('9000682')
    iam_sign_in(build(:iam_user))
    allow_any_instance_of(VAOS::UserService).to receive(:session).and_return('stubbed_token')
  end

  describe 'GET /mobile/v0/appointments/va/eligibility' do
    context 'valid params' do
      context 'one facility' do
        let(:params) { { facilityIds: 489 } }

        before do
          VCR.use_cassette('va_eligibility/get_scheduling_configurations_200', match_requests_on: %i[method uri]) do
            get '/mobile/v0/appointments/va/eligibility', params: params, headers: iam_headers
          end
        end

        it 'returns successful response' do
          expect(response).to have_http_status(:success)
        end

        it 'matches schema' do
          expect(response.body).to match_json_schema('service_eligibility')
        end

        it 'response only contains facilities from parameters' do
          facilties = response.parsed_body['data'].map { |h| h.dig('attributes', 'request') }.select(&:any?).uniq
          expect(facilties.size).to eq(1)

          expect(facilties.first).to eq(['489'])
        end
      end

      context 'multiple facilities' do
        let(:params) { { facilityIds: %w[489 984] } }

        before do
          VCR.use_cassette('va_eligibility/get_scheduling_configurations_200', match_requests_on: %i[method uri]) do
            get '/mobile/v0/appointments/va/eligibility', params: params, headers: iam_headers
          end
        end

        it 'returns successful response' do
          expect(response).to have_http_status(:success)
        end

        it 'matches schema' do
          expect(response.body).to match_json_schema('service_eligibility')
        end

        it 'response only contains facilities from parameters' do
          facilties = response.parsed_body['data'].map { |h| h.dig('attributes', 'request') }.select(&:any?).uniq
          expect(facilties.size).to eq(1)

          expect(facilties.first).to eq(['489'])
        end
      end
    end
  end
end
