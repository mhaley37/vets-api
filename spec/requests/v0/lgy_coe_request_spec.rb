# frozen_string_literal: true

require 'rails_helper'

vcr_options = {
  cassette_name: 'lgy/determine_elibile',
  match_requests_on: %i[path query]
}

describe 'LGY API', vcr: vcr_options do
  before(:all) do
    get v0_coe_status_url
  end

  context 'when user is signed in' do
    let(:user) { create(:evss_user, :loa3) }

    before { sign_in_as user }

    describe 'GET v0/coe/status' do
      context 'when determination is eligible and application is 404' do
        it 'response code is 200' do
          get '/v0/coe/status'
          expect(response).to have_http_status(:ok)
        end

        it 'response is in JSON format' do
          binding.pry
          get '/v0/coe/status'
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end

        it 'response status key is eligible' do
          get '/v0/coe/status'

          json_body = JSON.parse(response.body)
          expect(json_body['data']['attributes']).to include 'status' => 'eligible'
        end
      end
    end

    describe 'GET v0/coe/download' do
      context 'when COE file exists' do
        it 'response code is 200' do
          lgy_service = double('LGY Service')
          allow_any_instance_of(V0::CoeController).to receive(:lgy_service) { lgy_service }
          expect(lgy_service).to receive(:coe_url).and_return 'http://s3.aws.com/file'
          get '/v0/coe/download_coe'
          expect(response).to have_http_status(:ok)
        end

        it 'response is in JSON format' do
          lgy_service = double('LGY Service')
          allow_any_instance_of(V0::CoeController).to receive(:lgy_service) { lgy_service }
          expect(lgy_service).to receive(:coe_url).and_return 'http://s3.aws.com/file'
          get '/v0/coe/download_coe'
          expect(response.content_type).to eq('application/json; charset=utf-8')
        end

        it 'response url key is correct' do
          lgy_service = double('LGY Service')
          allow_any_instance_of(V0::CoeController).to receive(:lgy_service) { lgy_service }
          expect(lgy_service).to receive(:coe_url).and_return 'http://s3.aws.com/file'
          get '/v0/coe/download_coe'
          json_body = JSON.parse(response.body)
          expect(json_body['data']['attributes']).to eq 'url' => 'http://s3.aws.com/file'
        end
      end
    end
  end
end
