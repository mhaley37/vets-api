# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignIn::Logger do
  let(:logger) { SignIn::Logger.new }

  describe '#info_log' do
    let(:user_account) { create(:user_account) }
    let(:user) { create(:user, uuid: user_account.id) }
    let(:refresh_token) { create(:refresh_token, user_uuid: user_account.id) }
    let(:expected_token_hash) { Digest::SHA256.hexdigest(json_token) }
    let(:timestamp) { Time.zone.now }

    before do
      allow(User).to receive(:find).and_return(user)
      allow(Rails.logger).to receive(:info)
      allow(Time.zone).to receive(:now).and_return(timestamp)
    end

    context 'refresh token' do
      let(:message) { 'Sign in Service Token Response' }
      let(:code) { SecureRandom.hex }

      it 'logs the refresh token' do
        expect(Rails.logger).to receive(:info)
          .with(message,
                { code: code, token_type: 'refresh', user_id: user.uuid,
                  session_id: refresh_token.session_handle, timestamp: timestamp.to_s })
        logger.info_log(message, { code: code }, refresh_token)
      end
    end

    context 'access token' do
      let(:access_token) { create(:access_token, user_uuid: user_account.id) }
      let(:message) { 'Sign in Service Introspect' }

      it 'logs the access token' do
        expect(Rails.logger).to receive(:info)
          .with(message,
                { token_type: 'access', user_id: user.uuid, access_token_id: access_token.uuid,
                  session_id: access_token.session_handle, timestamp: timestamp.to_s })
        logger.info_log(message, {}, access_token)
      end
    end
  end
end
