# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignIn::TokenSerializer do
  let(:token_serializer) do
    SignIn::TokenSerializer.new(session_container: session_container, cookies: cookies)
  end

  describe '#perform' do
    subject { token_serializer.perform }

    let(:session_container) do
      create(:session_container,
             client_id: client_id,
             refresh_token: refresh_token,
             access_token: access_token,
             anti_csrf_token: anti_csrf_token)
    end
    let(:cookies) { {} }
    let(:refresh_token) { create(:refresh_token) }
    let(:access_token) { create(:access_token) }
    let(:anti_csrf_token) { 'some-anti-csrf-token' }
    let(:client_id) { SignIn::Constants::ClientConfig::CLIENT_IDS.first }
    let(:encoded_access_token) do
      SignIn::AccessTokenJwtEncoder.new(access_token: access_token).perform
    end
    let(:encrypted_refresh_token) do
      SignIn::RefreshTokenEncryptor.new(refresh_token: session_container.refresh_token).perform
    end

    context 'when client id is in the list of cookie auth clients' do
      let(:client_id) { SignIn::Constants::ClientConfig::COOKIE_AUTH.first }
      let(:access_token_expiration) { access_token.expiration_time }
      let(:refresh_token_expiration) { session_container.session.refresh_expiration }
      let(:info_cookie_value) do
        {
          access_token_expiration: access_token_expiration,
          refresh_token_expiration: refresh_token_expiration
        }
      end
      let(:path) { '/' }
      let(:secure) { Settings.sign_in.cookies_secure }
      let(:httponly) { true }
      let(:httponly_info_cookie) { false }
      let(:domain) { Settings.sign_in.info_cookie_domain }
      let(:refresh_path) { SignIn::Constants::Auth::REFRESH_ROUTE_PATH }
      let(:expected_access_token_cookie) do
        {
          value: encoded_access_token,
          expires: refresh_token_expiration,
          path: path,
          secure: secure,
          httponly: httponly
        }
      end
      let(:expected_refresh_token_cookie) do
        {
          value: encrypted_refresh_token,
          expires: refresh_token_expiration,
          path: refresh_path,
          secure: secure,
          httponly: httponly
        }
      end
      let(:expected_anti_csrf_token_cookie) do
        {
          value: anti_csrf_token,
          expires: refresh_token_expiration,
          path: path,
          secure: secure,
          httponly: httponly
        }
      end
      let(:expected_info_cookie) do
        {
          value: info_cookie_value,
          expires: refresh_token_expiration,
          secure: secure,
          domain: domain,
          httponly: httponly_info_cookie
        }
      end
      let(:access_token_cookie_name) { SignIn::Constants::Auth::ACCESS_TOKEN_COOKIE_NAME }
      let(:refresh_token_cookie_name) { SignIn::Constants::Auth::REFRESH_TOKEN_COOKIE_NAME }
      let(:anti_csrf_token_cookie_name) { SignIn::Constants::Auth::ANTI_CSRF_COOKIE_NAME }
      let(:info_cookie_name) { SignIn::Constants::Auth::INFO_COOKIE_NAME }

      it 'sets access token cookie' do
        subject
        expect(cookies[access_token_cookie_name]).to eq(expected_access_token_cookie)
      end

      it 'sets refresh token cookie' do
        subject
        expect(cookies[refresh_token_cookie_name]).to eq(expected_refresh_token_cookie)
      end

      it 'sets info cookie' do
        subject
        expect(cookies[info_cookie_name]).to eq(expected_info_cookie)
      end

      context 'and client id is in the list of anti csrf enabled clients' do
        it 'sets anti csrf token cookie' do
          subject
          expect(cookies[anti_csrf_token_cookie_name]).to eq(expected_anti_csrf_token_cookie)
        end

        it 'returns an empty hash' do
          expect(subject).to eq({})
        end
      end
    end

    context 'when client id is in the list of api auth clients' do
      let(:client_id) { SignIn::Constants::ClientConfig::API_AUTH.first }
      let(:token_payload) { { access_token: encoded_access_token, refresh_token: encrypted_refresh_token } }
      let(:expected_json_payload) { { data: token_payload } }

      context 'and client id is not in the list of anti csrf enabled clients' do
        it 'returns expected json payload' do
          expect(subject).to eq(expected_json_payload)
        end
      end
    end

    context 'when client id is arbitrary' do
      let(:client_id) { 'some-client-id' }
      let(:expected_error) { SignIn::Errors::InvalidClientIdError }
      let(:expected_error_message) { 'Client id is not valid' }

      it 'raises client id is not valid error' do
        expect { subject }.to raise_error(expected_error, expected_error_message)
      end
    end
  end
end
