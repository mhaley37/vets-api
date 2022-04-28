# frozen_string_literal: true

FactoryBot.define do
  factory :veteran_device_record, class: 'VeteranDeviceRecord' do
    user_uuid { SecureRandom.uuid }
    active { true }
    association :device
  end
end
