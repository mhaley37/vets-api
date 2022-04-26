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
end
