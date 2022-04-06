# frozen_string_literal: true

module VRE
  class Submit1900Job
    include Sidekiq::Worker
    attr_writer :retry_count

    sidekiq_retries_exhausted do |_msg, _e|
      @claim.send_to_central_mail!
    end

    def perform(claim_id, user_uuid)
      @claim = SavedClaim::VeteranReadinessEmploymentClaim.find claim_id
      @user = User.find user_uuid

      # since this is an expensive call to BGS, only do it the first run
      @claim.add_claimant_info(@user) if retry_count.zero?
      @claim.send_to_vre(@user)
    end

    def retry_count
      @retry_count || 0
    end
  end
end
