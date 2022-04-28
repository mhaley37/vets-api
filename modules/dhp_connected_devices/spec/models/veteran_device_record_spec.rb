# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VeteranDeviceRecord, type: :model do
  describe 'Veteran Device Record' do
    let(:current_user) { FactoryBot.build(:user) }

    before(:each) do
      @device = Device.create(name: 'Test Device')
    end

    after(:each) do
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
      vdr = VeteranDeviceRecord.new(
        user_uuid: current_user.uuid,
        device_id: @device.id,
        active: true
      )
      expect(vdr.device).to eq(@device)
    end
  end
end
