# frozen_string_literal: true

FactoryBot.define do
  factory :device, class: 'Device' do
    name { Faker::FunnyName.name }
  end
end
