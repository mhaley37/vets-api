# frozen_string_literal: true

require 'rails_helper'

describe VRE::Submit1900Job do
  describe '#perform' do
    subject { described_class.new.perform(claim.id, user.uuid) }

    let(:user) { create(:evss_user) }
    let(:claim) { create(:veteran_readiness_employment_claim) }

    before do
      allow(User).to receive(:find).and_return(user)
      allow(SavedClaim::VeteranReadinessEmploymentClaim).to receive(:find).and_return(claim)
    end

    it 'calls claim.add_claimant_info' do
      expect(claim).to receive(:add_claimant_info).with(user)
      subject
    end

    it 'calls claim.send_to_vre' do
      expect(claim).to receive(:send_to_vre).with(user)
      subject
    end
  end

  it 'acts like a job' do
    expect { described_class.perform_async }.to change { described_class.jobs.size }.by(1)
  end
end
