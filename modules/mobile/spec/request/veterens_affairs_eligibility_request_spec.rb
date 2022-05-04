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

        it 'response properly assigns facilities to services' do
          services = response.parsed_body.dig('data', 'attributes', 'services')

          expect(services).to eq(
            [{ 'name' => 'amputation',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => [] },
             { 'name' => 'audiology',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'covid',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'optometry',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'outpatientMentalHealth',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'moveProgram',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'foodAndNutrition',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'clinicalPharmacyPrimaryCare',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => '411',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'primaryCare',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'homeSleepTesting',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'socialWork',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] }]
          )
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

        it 'response properly assigns facilities to services' do
          services = response.parsed_body.dig('data', 'attributes', 'services')

          expect(services).to eq(
            [{ 'name' => 'amputation',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => [] },
             { 'name' => 'audiology',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => %w[489 984] },
             { 'name' => 'covid',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'optometry',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'outpatientMentalHealth',
               'requestEligibleFacilities' => ['984'],
               'directEligibleFacilities' => [] },
             { 'name' => 'moveProgram',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'foodAndNutrition',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => ['984'] },
             { 'name' => 'clinicalPharmacyPrimaryCare',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => ['984'] },
             { 'name' => '411',
               'requestEligibleFacilities' => %w[489 984],
               'directEligibleFacilities' => [] },
             { 'name' => 'primaryCare',
               'requestEligibleFacilities' => %w[489 984],
               'directEligibleFacilities' => ['984'] },
             { 'name' => 'homeSleepTesting',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'socialWork',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] }]
          )
        end
      end

      context 'all services enabled' do
        let(:params) { { facilityIds: 489 } }

        before do
          VCR.use_cassette('va_eligibility/get_scheduling_configurations_200_all_enabled',
                           match_requests_on: %i[method uri]) do
            get '/mobile/v0/appointments/va/eligibility', params: params, headers: iam_headers
          end
        end

        it 'returns successful response' do
          expect(response).to have_http_status(:success)
        end

        it 'matches schema' do
          expect(response.body).to match_json_schema('service_eligibility')
        end

        it 'all service ids are hit when parsing upstream response except for covid request' do
          services = response.parsed_body.dig('data', 'attributes', 'services')

          expect(services).to eq(
            [{ 'name' => 'amputation',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'audiology',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'covid',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'optometry',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'outpatientMentalHealth',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'moveProgram',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'foodAndNutrition',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' =>
                'clinicalPharmacyPrimaryCare',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => '411',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'primaryCare',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'homeSleepTesting',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] },
             { 'name' => 'socialWork',
               'requestEligibleFacilities' => ['489'],
               'directEligibleFacilities' => ['489'] }]
          )
        end
      end

      context 'bad facility' do
        let(:params) { { facilityIds: 12_345_678 } }

        before do
          VCR.use_cassette('va_eligibility/get_scheduling_configurations_200_bad_facility',
                           match_requests_on: %i[method uri]) do
            get '/mobile/v0/appointments/va/eligibility', params: params, headers: iam_headers
          end
        end

        it 'returns successful response' do
          expect(response).to have_http_status(:success)
        end

        it 'matches schema' do
          expect(response.body).to match_json_schema('service_eligibility')
        end

        it 'upstream service does not check for valid facility and returns no eligibility' do
          services = response.parsed_body.dig('data', 'attributes', 'services')

          expect(services).to eq(
            [{ 'name' => 'amputation',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'audiology',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'covid',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'optometry',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'outpatientMentalHealth',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'moveProgram',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'foodAndNutrition',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'clinicalPharmacyPrimaryCare',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => '411',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'primaryCare',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'homeSleepTesting',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] },
             { 'name' => 'socialWork',
               'requestEligibleFacilities' => [],
               'directEligibleFacilities' => [] }]
          )
        end
      end
    end
  end
end
