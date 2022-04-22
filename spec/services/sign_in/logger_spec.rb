# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignIn::Logger do
  let(:logger) { SignIn::Logger.new }

  describe '#log_token' do
    let(:user_account) { create(:user_account) }
    let(:user) { create(:user, uuid: user_account.id) }
    let(:refresh_token) { create(:refresh_token, user_uuid: user_account.id) }
    let(:expected_token_hash) { Digest::SHA256.hexdigest(json_token) }

    before { allow(User).to receive(:find).and_return(user) }

    context 'refresh token' do
      let(:json_token) { refresh_token.to_json }

      it 'logs the refresh token' do
        allow(Rails.logger).to receive(:info)
        expect(Rails.logger).to receive(:info)
          .with('Sign in Service Token - create:',
                hash_including(
                  token_type: 'refresh',
                  session_id: refresh_token.session_handle,
                  user_id: user.uuid,
                  refresh_token_hash: expected_token_hash
                ))
        logger.log_token(refresh_token, parent_refresh_token_hash: refresh_token.parent_refresh_token_hash)
      end
    end

    context 'access token' do
      let(:access_token) { create(:access_token, user_uuid: user_account.id) }
      let(:json_token) { access_token.to_json }

      it 'logs the access token' do
        allow(Rails.logger).to receive(:info)
        expect(Rails.logger).to receive(:info)
          .with('Sign in Service Token - create:',
                hash_including(
                  token_type: 'access',
                  session_id: access_token.session_handle,
                  user_id: user.uuid,
                  refresh_token_hash: access_token.refresh_token_hash,
                  access_token_hash: expected_token_hash
                ))
        logger.log_token(access_token, parent_refresh_token_hash: access_token.parent_refresh_token_hash)
      end
    end
  end
end
