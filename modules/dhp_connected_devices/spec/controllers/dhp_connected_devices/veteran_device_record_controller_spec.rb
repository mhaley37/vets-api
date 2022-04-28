# frozen_string_literal: true

require 'rails_helper'

Rspec.describe DhpConnectedDevices::VeteranDeviceRecordController, type: :request do
  let(:current_user) { build(:user, :loa1) }

  describe 'veteran_device_record#record' do
    context 'unauthenticated user' do
      # before { Flipper.enable(:dhp_connected_devices_fitbit) }

      it 'returns unauthenticated error' do
        get '/dhp_connected_devices/veteran-device-record'
        expect(response.status).to eq(401)
      end
    end

    context 'authenticated user' do
      before do
        devices = create_list(:device, 2)
        sign_in_as(current_user)
        devices.each do |device|
          VeteranDeviceRecord.create(user_uuid: current_user.uuid, device_id: device.id, active: true)
        end
      end

      after do
        VeteranDeviceRecord.delete_all
      end

      it 'returns veteran device record' do
        get '/dhp_connected_devices/veteran-device-record'
        json = JSON.parse(response.body)
        expect(json['devices'].length).to eq(2)
      end
    end
  end
end
