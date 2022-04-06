# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_spec_helper'

RSpec.describe InheritedProofingController, type: :controller do
  describe 'GET auth' do
    subject { get(:auth) }

    context 'when user is not authenticated' do
      let(:expected_error_title) { 'Not authorized' }

      it 'returns an unauthorized status' do
        expect(subject).to have_http_status(:unauthorized)
      end

      it 'renders not authorized error' do
        expect(JSON.parse(subject.body)['errors'].first['title']).to eq(expected_error_title)
      end
    end

    context 'when user is authenticated' do
      let(:icn) { '1013459302V141714' }
      let(:correlation_id) { '19031408' }
      let(:identity_info_url) { "#{Settings.mhv.inherited_proofing.base_path}/mhvacctinfo/#{correlation_id}" }
      let(:current_user) do
        build(:user, :mhv,
              mhv_icn: icn,
              mhv_correlation_id: correlation_id)
      end

      before { sign_in_as(current_user) }

      context 'and user is MHV eligible' do
        let(:identity_data_response) do
          {
            'mhvId' => 19031205, # rubocop:disable Style/NumericLiterals
            'identityProofedMethod' => 'IPA',
            'identityProofingDate' => '2020-12-14',
            'identityDocumentExist' => true,
            'identityDocumentInfo' => {
              'primaryIdentityDocumentNumber' => '73929233',
              'primaryIdentityDocumentType' => 'StateIssuedId',
              'primaryIdentityDocumentCountry' => 'United States',
              'primaryIdentityDocumentExpirationDate' => '2026-03-30'
            }
          }
        end
        let(:auth_code) { SecureRandom.hex }

        before do
          stub_request(:get, identity_info_url).to_return(
            body: identity_data_response.to_json
          )
          allow(SecureRandom).to receive(:hex).and_return(auth_code)
        end

        it 'renders Login.gov OAuth form with the MHV verifier auth_code' do
          expect(subject.body).to include("id=\"inherited_proofing_auth\" value=\"#{auth_code}\"")
        end

        it 'returns ok status' do
          expect(subject).to have_http_status(:ok)
        end
      end

      context 'and user is not MHV eligible' do
        let(:identity_data_failed_response) do
          {
            'mhvId' => 9712240, # rubocop:disable Style/NumericLiterals
            'identityDocumentExist' => false
          }
        end
        let(:expected_error) { InheritedProofing::Errors::IdentityDocumentMissingError.to_s }
        let(:expected_error_json) { { 'errors' => expected_error } }

        before do
          stub_request(:get, identity_info_url).to_return(
            body: identity_data_failed_response.to_json
          )
        end

        it 'renders identity document missing error' do
          expect(JSON.parse(subject.body)).to eq(expected_error_json)
        end

        it 'returns a bad request status' do
          expect(subject).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe 'GET user_attributes' do
    subject { get(:user_attributes) }

    context 'when authorization header does not exist' do
      let(:authorization_header) { nil }
      let(:expected_error) { InheritedProofing::Errors::AccessTokenMalformedJWTError.to_s }
      let(:expected_error_json) { { 'errors' => expected_error } }

      it 'renders Malformed JWT error' do
        expect(JSON.parse(subject.body)).to eq(expected_error_json)
      end

      it 'returns unauthorized status' do
        expect(subject).to have_http_status(:unauthorized)
      end
    end

    context 'when authorization header exists' do
      let(:authorization) { "Bearer #{access_token_jwt}" }
      let(:private_key) { OpenSSL::PKey::RSA.new(512) }
      let(:public_key) { private_key.public_key }
      let(:access_token_jwt) do
        JWT.encode(payload, private_key, InheritedProofing::JwtDecoder::JWT_ENCODE_ALROGITHM)
      end
      let(:payload) { { inherited_proofing_auth: auth_code, exp: expiration_time.to_i } }
      let(:expiration_time) { Time.zone.now + 5.minutes }
      let(:auth_code) { 'some-auth-code' }

      before do
        request.headers['Authorization'] = authorization
        allow_any_instance_of(InheritedProofing::JwtDecoder).to receive(:public_key).and_return(public_key)
      end

      context 'and access_token is some arbitrary value' do
        let(:access_token_jwt) { 'some-arbitrary-access-token' }
        let(:expected_error) { InheritedProofing::Errors::AccessTokenMalformedJWTError.to_s }
        let(:expected_error_json) { { 'errors' => expected_error } }

        it 'renders Malformed Params error' do
          expect(JSON.parse(subject.body)).to eq(expected_error_json)
        end

        it 'returns unauthorized status' do
          expect(subject).to have_http_status(:unauthorized)
        end
      end

      context 'and access_token is an expired JWT' do
        let(:expiration_time) { Time.zone.now - 1.day }
        let(:expected_error) { InheritedProofing::Errors::AccessTokenExpiredError.to_s }
        let(:expected_error_json) { { 'errors' => expected_error } }

        it 'renders access token expired error' do
          expect(JSON.parse(subject.body)).to eq(expected_error_json)
        end

        it 'returns unauthorized status' do
          expect(subject).to have_http_status(:unauthorized)
        end
      end

      context 'and access_token is an active JWT' do
        context 'and access_token payload does not have an inherited proofing auth field' do
          let(:payload) { { exp: expiration_time.to_i } }
          let(:expected_error) { InheritedProofing::Errors::AccessTokenMissingRequiredAttributesError.to_s }
          let(:expected_error_json) { { 'errors' => expected_error } }

          it 'renders access token missing required attributes error' do
            expect(JSON.parse(subject.body)).to eq(expected_error_json)
          end

          it 'returns unauthorized status' do
            expect(subject).to have_http_status(:unauthorized)
          end
        end

        context 'and access_token has an inherited proofing auth field' do
          let(:payload) { { inherited_proofing_auth: auth_code, exp: expiration_time.to_i } }

          context 'and there is not a mhv identity data object for the given auth code in the access token' do
            let(:expected_error) { InheritedProofing::Errors::MHVIdentityDataNotFoundError.to_s }
            let(:expected_error_json) { { 'errors' => expected_error } }

            it 'renders mhv identity data not found error' do
              expect(JSON.parse(subject.body)).to eq(expected_error_json)
            end

            it 'returns bad request status' do
              expect(subject).to have_http_status(:bad_request)
            end
          end

          context 'and there is a mhv identity data object for the given auth code in the access token' do
            let!(:mhv_identity_data) { create(:mhv_identity_data, code: auth_code, user_uuid: user.uuid) }
            let(:user) { create(:user) }

            before do
              allow_any_instance_of(InheritedProofing::UserAttributesEncryptor)
                .to receive(:public_key).and_return(public_key)
            end

            it 'renders expected encrypted user attributes' do
              encrypted_user_attributes = JSON.parse(subject.body)['data']
              decrypted_user_attributes = JWE.decrypt(encrypted_user_attributes, private_key)
              parsed_user_attributes = JSON.parse(decrypted_user_attributes)

              expect(parsed_user_attributes['first_name']).to eq(user.first_name)
              expect(parsed_user_attributes['last_name']).to eq(user.last_name)
              expect(parsed_user_attributes['address']).to eq(user.address.with_indifferent_access)
              expect(parsed_user_attributes['phone']).to eq(user.home_phone)
              expect(parsed_user_attributes['birth_date']).to eq(user.birth_date)
              expect(parsed_user_attributes['ssn']).to eq(user.ssn)
            end

            it 'returns ok status' do
              expect(subject).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end
end