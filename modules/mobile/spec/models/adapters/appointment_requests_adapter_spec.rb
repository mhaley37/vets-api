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

  let(:adapted_appointment_requests) do
    subject.parse(data)
  end

  it 'returns a list of appointment requests of the expected size' do
    expect(adapted_appointment_requests.count).to eq(2)
  end

  describe 'is_pending' do
    it 'is always true'
  end

  describe 'unused fields' do
    it 'returns them as nils'
    # cancel_id, comment, sta6aid, minutes_duration, vetext_id, is_covid_vaccine
  end

  describe 'phone_only' do
    it 'is true when visit type is "Phone Call"'
    it 'is false for all other visit types'
  end

  describe 'proposed_times' do
    it 'returns an array of date/time pairs in the order of the option dates/time in the source data'
  end

  describe 'time_zone' do
    it 'is based on facility zip code'
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
    it 'is SUBMITTED for submitted requests'
    it 'is CANCELLED for cancelled requests'
    it 'is skipped for any other request type'
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
      it 'is nil'
    end

    describe 'healthcare_service' do
      it 'is nil'
    end

    describe 'facility_id' do
      it 'returns the facility id matching the facility code'
      it 'returns nil when no facility id matches the facility code'
    end

    describe 'location' do
      it 'sets facility id and name but leaves everything else nil'
    end
  end

  context 'CC appointment requests' do
    describe 'appointment_type' do
      it 'is COMMUNITY_CARE'
      # is video possible?
    end

    describe 'healthcare_provider' do
      it 'is nil'
    end

    describe 'healthcare_service' do
      it 'is nil'
    end

    describe 'facility_id' do
      it 'returns the facility id matching the facility code'
      it 'returns nil when no facility id matches the facility code'
    end

    describe 'location' do
      it 'sets facility name to the practice name but leaves everything else nil'
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
