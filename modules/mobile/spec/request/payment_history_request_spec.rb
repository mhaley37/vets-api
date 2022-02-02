# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/iam_session_helper'
require_relative '../support/matchers/json_schema_matcher'

RSpec.describe 'payment_history', type: :request do
  include JsonSchemaMatchers

  before(:all) do
    @original_cassette_dir = VCR.configure(&:cassette_library_dir)
    VCR.configure { |c| c.cassette_library_dir = 'modules/mobile/spec/support/vcr_cassettes' }
  end

  after(:all) { VCR.configure { |c| c.cassette_library_dir = @original_cassette_dir } }

  before { iam_sign_in }
  describe 'GET /mobile/v0/payment-history' do
    context 'with successful response' do
      before do
        VCR.use_cassette('payment_history/retrieve_payment_summary_with_bdn', match_requests_on: %i[method uri]) do
          get '/mobile/v0/payment-history', headers: iam_headers, params: nil
        end
      end
      it 'should return 200' do
        binding.pry
        expect(response).to have_http_status(:ok)
      end
      it 'should match expected schema' do
        # binding.pry
        expect(response.body).to match_json_schema('payment_history')
      end
    end
  end

end