# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VeteranDeviceRecord, type: :model do
  it 'creates a Veteran Device Record' do
    expect(Device.new(name: 'fitbit')).to be_valid
  end
end