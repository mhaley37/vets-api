# frozen_string_literal: true

FactoryBot.define do
  factory :supplemental_claim, class: 'AppealsApi::SupplementalClaim' do
    id { SecureRandom.uuid }
    api_version { 'V2' }
    auth_headers do
      JSON.parse File.read "#{::Rails.root}/modules/appeals_api/spec/fixtures/valid_200995_headers.json"
    end
    form_data do
      JSON.parse File.read "#{::Rails.root}/modules/appeals_api/spec/fixtures/valid_200995.json"
    end
  end
end