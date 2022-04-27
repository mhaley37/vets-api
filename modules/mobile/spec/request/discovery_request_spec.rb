# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'discovery', type: :request do
  describe 'GET ../' do
    before { get '/mobile' }

    it 'returns a 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a welcome message' do
      expect(response.parsed_body).to eq(
        {
          'data' => {
            'attributes' => {
              'message' => 'Welcome to the mobile API'
            }
          }
        }
      )
    end
  end

  describe 'GET ../token' do
    context 'in the production environment' do
      before do
        Settings.hostname = 'api.va.gov'
        get '/mobile/token'
      end

      it 'returns a 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'in the staging environment' do
      before do
        Settings.hostname = 'staging-api.va.gov'
      end

      context 'when the feature flag is disabled' do
        before do
          Flipper.disable(:mobile_api_test_sessions)
          get '/mobile/token'
        end

        it 'returns a 401' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when the feature flag is enabled' do
        before do
          Flipper.enable(:mobile_api_test_sessions)
          get '/mobile/token'
        end

        context 'with no access token' do
          it 'returns a 401' do
            expect(response).to have_http_status(:unauthorized)
          end
        end

        context 'with an access token that contains a valid user' do
          let(:identity_args) do
            {
              birth_date: '1953-04-01',
              email: 'judy.morrison@id.me',
              expiration_timestamp: Time.now.to_i + 60 * 5,
              first_name: 'JUDY',
              gender: 'F',
              iam_edipi: '1259897978',
              iam_mhv_id: '16701377',
              iam_sec_id: '0000027819',
              icn: '1012845331V153043',
              last_name: 'MORRISON',
              loa: {
                current: 3,
                highest: 3
              },
              middle_name: 'SNOW',
              sign_in: { service_name: 'oauth_IDME', account_type: '3' },
              ssn: '796061976',
              uuid: '16c9faba-2d6f-4458-8b33-1063070b9ed0'
            }
          end

          let(:headers) do
            token = JWT.encode identity_args, 'fake_secret', 'HS256'
            {
              'Authorization' => "Bearer #{token}"
            }
          end

          it 'returns a 200' do
            expect(response).to have_http_status(:unauthorized)
          end
        end
      end
    end
  end
end
