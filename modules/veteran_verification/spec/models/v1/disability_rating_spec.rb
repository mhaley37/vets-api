# frozen_string_literal: true

require 'rails_helper'

describe VeteranVerification::V1::DisabilityRating do
  let(:user) { build(:openid_user, identity_attrs: build(:user_identity_attrs, :loa3, ssn: '796126777')) }

  before do
    Settings.vet_verification.mock_bgs = false
  end

  describe '#formatted_ratings' do
    it 'returns combined rating and list of individual_ratings' do
      VCR.use_cassette('bgs/rating_web_service/rating_data') do
        result = described_class.for_user(user)
        expect(result[:combined_disability_rating]).to eq(100)
        expect(result[:combined_effective_date]).to eq('2019-01-01')
        expect(result[:legal_effective_date]).to eq('2018-12-31')
        expect(result[:individual_ratings][0][:decision]).to eq('Service Connected')
        expect(result[:individual_ratings][0][:effective_date]).to eq(Date.parse('2005-01-01'))
        expect(result[:individual_ratings][0][:rating_percentage]).to eq(100)
      end
    end

    it 'returns combined rating and one individual_rating' do
      VCR.use_cassette('bgs/rating_web_service/rating_data_single_rating') do
        result = described_class.for_user(user)
        expect(result[:combined_disability_rating]).to eq(100)
        expect(result[:combined_effective_date]).to eq('2019-01-01')
        expect(result[:legal_effective_date]).to eq('2018-12-31')
        expect(result[:individual_ratings][0][:decision]).to eq('Service Connected')
        expect(result[:individual_ratings][0][:effective_date]).to eq(Date.parse('2005-01-01'))
        expect(result[:individual_ratings][0][:rating_percentage]).to eq(100)
      end
    end

    it 'record has no individual_ratings' do
      VCR.use_cassette('bgs/rating_web_service/rating_data_no_ratings') do
        result = described_class.for_user(user)
        expect(result[:combined_disability_rating]).to eq(100)
        expect(result[:combined_effective_date]).to eq('2019-01-01')
        expect(result[:legal_effective_date]).to eq('2018-12-31')
      end
    end
  end
end
