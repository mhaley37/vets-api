# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VeteranDeviceRecord, type: :model do
  describe 'Veteran Device Record' do
    let(:current_user) { FactoryBot.build(:user) }

    before do
      @device = Device.create(name: 'Test Device')
    end

    after do
      Device.delete(@device.name)
    end

    it 'creates a Veteran Device Record' do
      expect(VeteranDeviceRecord.new(user_uuid: current_user.uuid, device_id: @device.id,
                                     active: true)).to be_valid
    end

    it 'requires user_uuid' do
      expect(VeteranDeviceRecord.new(device_id: @device.id, active: true)).not_to be_valid
    end

    it 'requires device_id' do
      expect(VeteranDeviceRecord.new(user_uuid: current_user.uuid, active: true)).not_to be_valid
    end

    it 'requires active' do
      expect(VeteranDeviceRecord.new(user_uuid: current_user.uuid, device_id: @device.id)).not_to be_valid
    end

    it 'has a device' do
      vdr = create(:veteran_device_record, device_id: @device.id)
      expect(vdr.device).to eq(@device)
    end

    it '#active_devices()' do
      vdr = create(:veteran_device_record, device_id: @device.id, user_uuid: current_user.uuid)
      veteran_active_devices = VeteranDeviceRecord.active_devices(current_user)
      expect(veteran_active_devices.first).to eq(vdr)
    end

    it 'will not create record if user ID and device ID combination exist' do
      VeteranDeviceRecord.create(device_id: @device.id, user_uuid: current_user.uuid, active: true)
      expect(VeteranDeviceRecord.create(user_uuid: current_user.uuid, device_id: @device.id,
                                        active: true)).not_to be_valid
      VeteranDeviceRecord.delete_all
    end
  end
end
