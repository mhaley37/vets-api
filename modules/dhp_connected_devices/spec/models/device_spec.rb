# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Device, type: :model do
  it 'creates device when given a name' do
    expect(Device.new(name: 'fitbit')).to be_valid
  end

  it 'has a unique device name' do
    Device.create(name: 'fitbit')
    expect(Device.create(name: 'fitbit')).not_to be_valid
  end

  it 'cannot create a device without a name' do
    expect(Device.new).not_to be_valid
  end

  it 'has many veteran_device_records' do
    device = create(:device)
    vdrs = create_list(:veteran_device_record, 3, device_id: device.id)
    expect(device.veteran_device_records.count).to eq(3)
    expect(device.veteran_device_records).to eq(vdrs)
  end
end
