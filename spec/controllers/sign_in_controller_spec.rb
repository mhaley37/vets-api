# frozen_string_literal: true

require 'rails_helper'
require 'support/saml/form_validation_helpers'

RSpec.describe SignInController, type: :controller do
  include SAML::ValidationHelpers

  context 'when not logged in' do
    describe 'GET new' do
      context 'routes not requiring auth' do
        %w[logingov].each do |type|
          context "routes /sign_in/#{type}/new to SignInController#new with type: #{type}" do
            let(:url) do
              case type
              when 'logingov'
                'https://idp.int.identitysandbox.gov/openid_connect/authorize'
              end
            end

            it 'presents login form' do
              expect(get(:new, params: { type: type }))
                .to have_http_status(:ok)
              expect_oauth_post_form(response.body, "#{type}-form", url)
            end
          end
        end
      end
    end

    describe 'GET callback' do
      %w[logingov].each do |type|
        context 'successful authentication' do
          it 'redirects user to home page' do
            VCR.use_cassette("identity/#{type}_200_responses") do
              post(:callback, params: { type: type, code: '6805c923-9f37-4b47-a5c9-214391ddffd5' })
              expect(response).to redirect_to("http://localhost:3001/auth/login/callback?type=#{type}")
            end
          end
        end

        context 'unsuccessful authentication' do
          it 'redirects to an auth failure page' do
            VCR.use_cassette("identity/#{type}_400_responses") do
              expect(controller).to receive(:log_message_to_sentry)
                .with(
                  'the server responded with status 400',
                  :error
                )
              post(:callback, params: { type: type, code: '6805c923-9f37-4b47-a5c9-214391ddffd5' })
              expect(response).to redirect_to('http://localhost:3001/auth/login/callback?auth=fail&code=007')
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end

  describe 'POST refresh' do
    subject { post(:refresh, params: {}.merge(refresh_token_param).merge(anti_csrf_token_param)) }

    let(:refresh_token_param) { { refresh_token: refresh_token } }
    let(:anti_csrf_token_param) { { anti_csrf_token: anti_csrf_token } }
    let(:refresh_token) { 'some-refresh-token' }
    let(:anti_csrf_token) { 'some-anti-csrf-token' }

    context 'when refresh_token and anti_csrf_token param is given' do
      context 'and refresh_token is an arbitrary string' do
        let(:refresh_token) { 'some-refresh-token' }
        let(:expected_error) { 'Decryption failed' }
        let(:expected_error_json) { { 'errors' => expected_error } }

        it 'renders Decryption failed error' do
          expect(JSON.parse(subject.body)).to eq(expected_error_json)
        end

        it 'returns unauthorized status' do
          expect(subject).to have_http_status(:unauthorized)
        end
      end

      context 'and refresh_token is the proper encrypted refresh token format' do
        let(:user_account) { create(:user_account) }
        let(:session_container) { SignIn::SessionCreator.new(user_account: user_account).perform }
        let(:refresh_token) do
          SignIn::RefreshTokenEncryptor.new(refresh_token: session_container.refresh_token).perform
        end
        let(:anti_csrf_token) { session_container.anti_csrf_token }

        context 'and encrypted component has been modified' do
          let(:expected_error) { 'Decryption failed' }
          let(:expected_error_json) { { 'errors' => expected_error } }

          let(:refresh_token) do
            token = SignIn::RefreshTokenEncryptor.new(refresh_token: session_container.refresh_token).perform
            split_token = token.split('.')
            split_token[0] = 'some-modified-encrypted-component'
            split_token.join
          end

          it 'renders Decryption failed error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and nonce component has been modified' do
          let(:expected_error) { SignIn::Errors::RefreshNonceMismatchError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          let(:refresh_token) do
            token = SignIn::RefreshTokenEncryptor.new(refresh_token: session_container.refresh_token).perform
            split_token = token.split('.')
            split_token[1] = 'some-modified-nonce-component'
            split_token.join('.')
          end

          it 'renders a nonce mismatch error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and version has been modified' do
          let(:expected_error) { SignIn::Errors::RefreshVersionMismatchError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          let(:refresh_token) do
            token = SignIn::RefreshTokenEncryptor.new(refresh_token: session_container.refresh_token).perform
            split_token = token.split('.')
            split_token[2] = 'some-modified-version-component'
            split_token.join('.')
          end

          it 'renders a version mismatch error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and anti_csrf_token has been modified' do
          let(:expected_error) { SignIn::Errors::AntiCSRFMismatchError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          let(:anti_csrf_token) { 'some-modified-anti-csrf-token' }

          it 'renders an anti csrf mismatch error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and refresh token is expired' do
          let(:expected_error) { SignIn::Errors::SessionNotAuthorizedError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          before do
            session = session_container.session
            session.refresh_expiration = 1.day.ago
            session.save!
          end

          it 'renders a session not authorized error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and refresh token does not map to an existing session' do
          let(:expected_error) { SignIn::Errors::SessionNotAuthorizedError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          before do
            session = session_container.session
            session.destroy!
          end

          it 'renders a session not authorized error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and refresh token is not a parent or child according to the session' do
          let(:expected_error) { SignIn::Errors::TokenTheftDetectedError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          before do
            session = session_container.session
            session.hashed_refresh_token = 'some-unrelated-refresh-token'
            session.save!
          end

          it 'renders a session not authorized error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and both refresh token and anti csrf token are unmodified and valid' do
          it 'returns ok status' do
            expect(subject).to have_http_status(:ok)
          end

          it 'returns expected body with access token' do
            expect(JSON.parse(subject.body)['data']).to have_key('access_token')
          end

          it 'returns expected body with refresh token' do
            expect(JSON.parse(subject.body)['data']).to have_key('refresh_token')
          end

          it 'returns expected body with anti csrf token token' do
            expect(JSON.parse(subject.body)['data']).to have_key('anti_csrf_token')
          end
        end
      end
    end

    context 'when refresh_token param is not given' do
      let(:expected_error) { SignIn::Errors::MalformedParamsError.to_s }
      let(:expected_error_json) { { 'errors' => expected_error } }
      let(:refresh_token_param) { {} }

      it 'renders Malformed Params error' do
        expect(JSON.parse(subject.body)).to eq(expected_error_json)
      end

      it 'returns unauthorized status' do
        expect(subject).to have_http_status(:unauthorized)
      end
    end

    context 'when anti_csrf_token param is not given' do
      let(:expected_error) { SignIn::Errors::MalformedParamsError.to_s }
      let(:expected_error_json) { { 'errors' => expected_error } }
      let(:anti_csrf_token_param) { {} }

      it 'renders Malformed Params error' do
        expect(JSON.parse(subject.body)).to eq(expected_error_json)
      end

      it 'returns unauthorized status' do
        expect(subject).to have_http_status(:unauthorized)
      end
    end
  end
end
