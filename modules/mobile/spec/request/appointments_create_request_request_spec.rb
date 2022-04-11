# frozen_string_literal: true

require 'rails_helper'
require 'vaos_appointments/appointments_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'vaos appointments', type: :request, skip_mvi: true do
  include SchemaMatchers
  mock_clinic = {
    'service_name': 'service_name',
    'physical_location': 'physical_location'
  }

  mock_facility = {
    'test' => 'test'
  }

  before do
    Flipper.enable('va_online_scheduling')
    allow_any_instance_of(IAMUser).to receive(:icn).and_return('1012846043V576341')
    iam_sign_in(build(:iam_user))
    allow_any_instance_of(VAOS::UserService).to receive(:session).and_return('stubbed_token')
    allow_any_instance_of(VAOSAppointments::AppointmentsHelper).to receive(:get_clinic).and_return(mock_clinic)
    allow_any_instance_of(VAOSAppointments::AppointmentsHelper).to receive(:get_facility).and_return(mock_facility)
  end

  context 'with iam user' do

    describe 'CREATE cc appointment' do
      let(:community_cares_request_body) do
        FactoryBot.build(:appointment_form_v2, :community_cares).attributes
      end

      it 'creates the cc appointment' do
        VCR.use_cassette('vaos/v2/appointments/post_appointments_cc_200_2222022', match_requests_on: %i[method uri]) do
          post '/mobile/v0/appointments/requests', params: community_cares_request_body, headers: iam_headers
          expect(response).to have_http_status(:created)
          expect(json_body_for(response)).to match_camelized_schema('vaos/v2/appointment', { strict: false })
        end
      end

      it 'returns a 400 error' do
        VCR.use_cassette('vaos/v2/appointments/post_appointments_400', match_requests_on: %i[method uri]) do
          post '/mobile/v0/appointments/requests', params: community_cares_request_body, headers: iam_headers
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['errors'][0]['status']).to eq('400')
          expect(JSON.parse(response.body)['errors'][0]['detail']).to eq(
                                                                        'the patientIcn must match the ICN in the request URI'
                                                                      )
        end
      end
    end

    describe 'CREATE va appointment' do
      let(:va_booked_request_body) do
        FactoryBot.build(:appointment_form_v2, :va_booked).attributes
      end

      let(:va_proposed_request_body) do
        FactoryBot.build(:appointment_form_v2, :va_proposed_clinic).attributes
      end

      it 'creates the va appointment - proposed' do
        VCR.use_cassette('vaos/v2/appointments/post_appointments_va_proposed_clinic_200',
                         match_requests_on: %i[method uri]) do
          post '/mobile/v0/appointments/requests', params: va_proposed_request_body, headers: iam_headers
          expect(response).to have_http_status(:created)
          expect(json_body_for(response)).to match_camelized_schema('vaos/v2/appointment', { strict: false })
        end
      end

      it 'creates the va appointment - booked' do
        VCR.use_cassette('vaos/v2/appointments/post_appointments_va_booked_200_JACQUELINE_M',
                         match_requests_on: %i[method uri]) do
          post '/mobile/v0/appointments/requests', params: va_proposed_request_body, headers: iam_headers
          expect(response).to have_http_status(:created)
          expect(json_body_for(response)).to match_camelized_schema('vaos/v2/appointment', { strict: false })
        end
      end
    end
  end
end
