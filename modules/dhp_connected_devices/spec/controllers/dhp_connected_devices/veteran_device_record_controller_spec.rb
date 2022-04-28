# frozen_string_literal: true

require 'rails_helper'

Rspec.describe DhpConnectedDevices::VeteranDeviceRecordController, type: :request do
  let(:current_user) { build(:user, :loa1) }
  let(:device) { FactoryBot.build(:device) }

  describe 'veteran_device_record#record' do
    def get_vdr
      get '/dhp_connected_devices/veteran-device-record'
    end

    context 'unauthenticated user' do
      # before { Flipper.enable(:dhp_connected_devices_fitbit) }

      it 'returns unauthenticated error' do
        expect(get_vdr).to be 401
      end
    end

    context 'authenticated user' do
      before do
        sign_in_as(current_user)
        @vdr = VeteranDeviceRecord.create(
          user_uuid: current_user.uuid,
          device_id: device.id,
          active: true
        )
        # Flipper.enable(:dhp_connected_devices_fitbit)
      end

      after do
        VeteranDeviceRecord.delete(@vdr)
      end

      it 'returns veteran device record' do
        response = get_vdr
        expect(response.body).to eq('Record')
      end
    end
  end
end
