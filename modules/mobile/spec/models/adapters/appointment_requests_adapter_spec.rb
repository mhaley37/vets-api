# frozen_string_literal: true

require 'rails_helper'

describe Mobile::V0::Adapters::AppointmentRequests do
  let(:appointment_fixtures) do
    File.read(Rails.root.join('modules', 'mobile', 'spec', 'support', 'fixtures', 'appointment_requests.json'))
  end
  let(:data) do
    parsed = JSON.parse(appointment_fixtures, symbolize_names: true)
    parsed.map { |request| OpenStruct.new(request) }
  end
  let(:submitted_va_appt_request) do
    va_appointment_requests.find { |request| request.id == '8a48e8db6d70a38a016d72b354240002' }
  end
  let(:cancelled_cc_appt_request) do
    cc_appointment_requests.find { |request| request.id == '8a48912a6d02b0fc016d20b4ccb9001a' }
  end
  # let(:booked_request) { data.find { |d| d.appointment_request_id == '8a48dea06c84a667016c866de87c000b' } }
  # let(:resolved_request) { data.find { |d| d.appointment_request_id == '8a48e8db6d7682c3016d88dc21650024' } }
  let(:adapted_appointment_requests) do
    subject.parse(data)
  end
  let(:va_appointment_requests) { adapted_appointment_requests[0] }
  let(:cc_appointment_requests) { adapted_appointment_requests[1] }
  let(:all_appointment_requests) { [va_appointment_requests + cc_appointment_requests].flatten }

  it 'returns lists of va and cc appointment requests' do
    expect(adapted_appointment_requests).to eq([[submitted_va_appt_request], [cancelled_cc_appt_request]])
  end

  describe 'is_pending' do
    it 'is always true' do
      is_pending = all_appointment_requests.collect(&:is_pending).uniq
      expect(is_pending).to eq([true])
    end
  end

  describe 'unused fields' do
    it 'returns them as nils' do
      cancel_id = all_appointment_requests.collect(&:cancel_id).uniq
      comment = all_appointment_requests.collect(&:comment).uniq
      sta6aid = all_appointment_requests.collect(&:sta6aid).uniq
      minutes_duration = all_appointment_requests.collect(&:minutes_duration).uniq
      vetext_id = all_appointment_requests.collect(&:vetext_id).uniq
      is_covid_vaccine = all_appointment_requests.collect(&:is_covid_vaccine).uniq

      expect([cancel_id, comment, sta6aid, minutes_duration, vetext_id, is_covid_vaccine]).to all(eq([nil]))
    end
  end

  describe 'phone_only' do
    it 'is true when visit type is "Phone Call"' do
      # need test data
    end

    it 'is false for all other visit types' do
      expect(submitted_va_appt_request[:phone_only]).to eq(false)
      expect(cancelled_cc_appt_request[:phone_only]).to eq(false)
    end
  end

  describe 'proposed_times' do
    it 'returns an array of date/time pairs in the order of the option dates/time in the source data' do
    end
  end

  describe 'time_zone' do
    it 'is based on facility zip code' do
    end
  end

  describe 'start_date_local/start_date_utc' do
    it 'uses the time zone' do
    end

    context 'when all proposed dates are past' do
      it 'is based on the chronologically first proposed date'
    end

    context 'when any proposed date is in the future' do
      it 'is based on the chronologically first proposed date in the future'
    end
  end

  describe 'status' do
    it 'is SUBMITTED for submitted requests' do
      expect(submitted_va_appt_request.status).to eq('SUBMITTED')
    end

    it 'is CANCELLED for cancelled requests' do
      expect(cancelled_cc_appt_request.status).to eq('CANCELLED')
    end

    it 'is skipped for any other request type' do
      # pending
    end
  end

  describe 'status_detail' do
    # based on detail code
  end

  context 'VA appointment requests' do
    describe 'appointment_type' do
      it 'is VA for office visits and phone calls'

      it 'is VA_VIDEO_CONNECT_HOME for video conference visits'
    end

    describe 'healthcare_provider' do
      it 'is nil' do
        expect(submitted_va_appt_request.healthcare_provider).to be_nil
      end
    end

    describe 'healthcare_service' do
      it 'is nil' do
        expect(submitted_va_appt_request.healthcare_service).to be_nil
      end
    end

    describe 'facility_id' do
      it 'returns the facility id matching the facility code' do
        expect(submitted_va_appt_request.facility_id).to eq('442')
      end

      it 'returns nil when no facility id matches the facility code'
    end

    describe 'location' do
      it 'sets facility id and name but leaves everything else nil' do
        expected_location = {
          id: '442',
          name: 'CHEYENNE VAMC',
          address: { street: nil, city: nil, state: nil, zip_code: nil },
          lat: nil,
          long: nil,
          phone: { area_code: nil, number: nil, extension: nil },
          url: nil,
          code: nil
        }
        expect(submitted_va_appt_request.location.to_h).to eq(expected_location)
      end
    end
  end

  context 'CC appointment requests' do
    describe 'appointment_type' do
      it 'is COMMUNITY_CARE' do
      end
    end

    describe 'healthcare_provider' do
      it "is the healthcare provider's first and last name" do
        expect(cancelled_cc_appt_request.healthcare_provider).to eq('Vilasini Reddy')
      end
    end

    describe 'healthcare_service' do
      it "is the preferred provider's practice name" do
        expect(cancelled_cc_appt_request.healthcare_service).to eq('Test clinic 2')
      end
    end

    describe 'facility_id' do
      it 'is nil' do
        expect(cancelled_cc_appt_request.facility_id).to be_nil
      end
    end

    describe 'location' do
      it 'sets name, address, and phone' do
        expected_location = {
          id: nil,
          name: 'Test clinic 2',
          address: { street: '123 Sesame St.', city: 'Cheyenne', state: 'VA', zip_code: '20171' },
          lat: nil,
          long: nil,
          phone: { area_code: '703', number: '652-0000', extension: nil },
          url: nil,
          code: nil
        }
        expect(cancelled_cc_appt_request.location.to_h).to eq(expected_location)
      end
    end
  end

  context 'Office request' do
  end

  context 'Phone request' do
  end

  context 'Video request' do
  end

  context 'Unknown type' do
  end
end
