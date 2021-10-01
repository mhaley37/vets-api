# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'VirtualAgentAppeals', type: :request do
  let(:user) { create(:user, :loa3, ssn: '111223333') }

  describe 'GET /v0/virtual_agent/appeal' do
    it 'returns information when most recent open appeal is compensation' do
      sign_in_as(user)
      # run job
      VCR.use_cassette('caseflow/virtual_agent_appeals/recent_open_compensation_appeal') do
        get '/v0/virtual_agent/appeal'
        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(JSON.parse(response.body)['data'].size).to equal(1)
        expect(res_body[0]).to include({
                                         'appeal_type' => 'Compensation',
                                         'filing_date' => '06/11/2008',
                                         'appeal_status' => 'Please review your Supplemental Statement of the Case',
                                         'updated_date' => '01/16/2018',
                                         'description' => ' '
                                       })
      end
    end

    it 'returns empty array when no appeals are found' do
      sign_in_as(user)

      VCR.use_cassette('caseflow/appeals_empty') do
        get '/v0/virtual_agent/appeal'
        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(res_body.size).to equal(0)
      end
    end

    it 'returns most recent appeal that is compensation and active' do
      sign_in_as(user)
      VCR.use_cassette('caseflow/virtual_agent_appeals/appeals_old_comp') do
        get '/v0/virtual_agent/appeal'
        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(res_body.size).to equal(1)
        expect(res_body[0]).to include({
                                         'appeal_type' => 'Compensation',
                                         'filing_date' => '01/06/2003',
                                         'appeal_status' => 'Your appeal was closed',
                                         'description' => ' (Service connection, sleep apnea) ',
                                         'updated_date' => '09/30/2003',
                                         'appeal_or_review' => 'appeal'
                                       })
      end
    end

    it 'returns an empty array when no active compensation appeals are found' do
      sign_in_as(user)

      VCR.use_cassette('caseflow/virtual_agent_appeals/appeals_inactive_comp') do
        get '/v0/virtual_agent/appeal'

        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(res_body.size).to equal(0)
      end
    end

    it 'returns an empty array when no active appeals are found' do
      sign_in_as(user)

      VCR.use_cassette('caseflow/virtual_agent_appeals/appeals_inactive') do
        get '/v0/virtual_agent/appeal'
        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(res_body.size).to equal(0)
      end
    end

    it 'returns correct appeal status message for field grant appeal status type' do
      sign_in_as(user)

      VCR.use_cassette('caseflow/virtual_agent_appeals/appeals_field_grant_status_type') do
        get '/v0/virtual_agent/appeal'
        res_body = JSON.parse(response.body)['data']
        expect(response).to have_http_status(:ok)
        expect(res_body).to be_kind_of(Array)
        expect(res_body.size).to equal(1)
        expect(res_body[0]).to include({
                                         'appeal_type' => 'Compensation',
                                         'filing_date' => '06/11/2008',
                                         'appeal_status' => 'The Veterans Benefits Administration granted your appeal',
                                         'updated_date' => '01/16/2018',
                                         'description' => ' ',
                                         'appeal_or_review' => 'appeal'
                                       })
      end
    end

    describe 'get appeal or review based on appeal type' do
      it 'returns appeal when appeal type is legacyAppeal ' do
        sign_in_as(user)
        # run job
        VCR.use_cassette('caseflow/virtual_agent_appeals/recent_open_compensation_appeal') do
          get '/v0/virtual_agent/appeal'
          res_body = JSON.parse(response.body)['data']
          expect(response).to have_http_status(:ok)
          expect(res_body).to be_kind_of(Array)
          expect(JSON.parse(response.body)['data'].size).to equal(1)
          expect(res_body[0]).to include({
                                           'appeal_type' => 'Compensation',
                                           'filing_date' => '06/11/2008',
                                           'appeal_status' => 'Please review your Supplemental Statement of the Case',
                                           'updated_date' => '01/16/2018',
                                           'description' => ' ',
                                           'appeal_or_review' => 'appeal'
                                         })
        end
      end

      it 'returns appeal when appeal type is appeal ' do
        sign_in_as(user)
        # run job
        VCR.use_cassette('caseflow/virtual_agent_appeals/appeal_type_is_appeal') do
          get '/v0/virtual_agent/appeal'
          res_body = JSON.parse(response.body)['data']
          expect(response).to have_http_status(:ok)
          expect(res_body).to be_kind_of(Array)
          expect(JSON.parse(response.body)['data'].size).to equal(1)
          expect(res_body[0]).to include({
                                           'appeal_type' => 'Compensation',
                                           'filing_date' => '06/11/2008',
                                           'appeal_status' => 'Please review your Supplemental Statement of the Case',
                                           'updated_date' => '01/16/2018',
                                           'description' => ' ',
                                           'appeal_or_review' => 'appeal'
                                         })
        end
      end

      it 'returns review when appeal type is higherLevelReview ' do
        sign_in_as(user)
        # run job
        VCR.use_cassette('caseflow/virtual_agent_appeals/appeal_type_is_higher_level_review') do
          get '/v0/virtual_agent/appeal'
          res_body = JSON.parse(response.body)['data']
          expect(response).to have_http_status(:ok)
          expect(res_body).to be_kind_of(Array)
          expect(JSON.parse(response.body)['data'].size).to equal(1)
          expect(res_body[0]).to include({
                                           'appeal_type' => 'Compensation',
                                           'filing_date' => '06/11/2008',
                                           'appeal_status' => 'Please review your Supplemental Statement of the Case',
                                           'updated_date' => '01/16/2018',
                                           'description' => ' ',
                                           'appeal_or_review' => 'review'
                                         })
        end
      end

      it 'returns review when appeal type is supplementalClaim ' do
        sign_in_as(user)
        # run job
        VCR.use_cassette('caseflow/virtual_agent_appeals/appeal_type_is_supplemental_claim') do
          get '/v0/virtual_agent/appeal'
          res_body = JSON.parse(response.body)['data']
          expect(response).to have_http_status(:ok)
          expect(res_body).to be_kind_of(Array)
          expect(JSON.parse(response.body)['data'].size).to equal(1)
          expect(res_body[0]).to include({
                                           'appeal_type' => 'Compensation',
                                           'filing_date' => '06/11/2008',
                                           'appeal_status' => 'Please review your Supplemental Statement of the Case',
                                           'updated_date' => '01/16/2018',
                                           'description' => ' ',
                                           'appeal_or_review' => 'review'
                                         })
        end
      end


      describe "returns multiple appeals as an array" do

          it 'only returns active comp appeals ' do
            sign_in_as(user)
            # run job
            VCR.use_cassette('caseflow/virtual_agent_appeals/three_appeals_two_open_comp') do
              get '/v0/virtual_agent/appeal'
              res_body = JSON.parse(response.body)['data']
              expect(response).to have_http_status(:ok)
              expect(res_body).to be_kind_of(Array)
              expect(res_body.length).to equal(2)
              expect(res_body).to eq([{
                                       'appeal_type' => 'Compensation',
                                       'filing_date' => '09/30/2021',
                                       'appeal_status' => 'Your appeal is waiting to be sent to a judge',
                                       'updated_date' => '09/30/2021',
                                       'description' => ' ',
                                       'appeal_or_review' => 'appeal'
                                     },{
                                       'appeal_type' => 'Compensation',
                                       'filing_date' => '01/06/2003',
                                       'appeal_status' => 'The Board made a decision on your appeal',
                                       'updated_date' => '09/15/2021',
                                       'description' => ' ',
                                       'appeal_or_review' => 'appeal'
                                     }])
          end
         end

          it 'only returns five active comp appeals when more than five are found' do
            sign_in_as(user)
            # run job
            VCR.use_cassette('caseflow/virtual_agent_appeals/six_open_comp_appeals_five_returned') do
              get '/v0/virtual_agent/appeal'
              res_body = JSON.parse(response.body)['data']
              expect(response).to have_http_status(:ok)
              expect(res_body).to be_kind_of(Array)
              expect(res_body.length).to equal(5)
              expect(res_body).to eq([{
                                        "appeal_type" => "Compensation",
                                        "filing_date" => "09/30/2021",
                                        "appeal_status" => "Your appeal is waiting to be sent to a judge",
                                        "updated_date" => "09/30/2021",
                                        "description" => " ",
                                        "appeal_or_review" => "appeal"
                                      }, {
                                        "appeal_type" => "Compensation",
                                        "filing_date" => "09/29/2021",
                                        "appeal_status" => "Your appeal is waiting to be sent to a judge",
                                        "updated_date" => "09/29/2021",
                                        "description" => " ",
                                        "appeal_or_review" => "appeal"
                                      }, {
                                        "appeal_type" => "Compensation",
                                        "filing_date" => "03/06/2021",
                                        "appeal_status" => "The Board made a decision on your appeal",
                                        "updated_date" => "09/15/2021",
                                        "description" => " ",
                                        "appeal_or_review" => "appeal"
                                      }, {
                                        "appeal_type" => "Compensation",
                                        "filing_date" => "02/06/2003",
                                        "appeal_status" => "Your appeal was closed",
                                        "updated_date" => "10/01/2021",
                                        "description" => " ",
                                        "appeal_or_review" => "appeal"
                                      }, {
                                        "appeal_type" => "Compensation",
                                        "filing_date" => "01/06/2003",
                                        "appeal_status" => "The Board made a decision on your appeal",
                                        "updated_date" => "09/16/2021",
                                        "description" => " ",
                                        "appeal_or_review" => "appeal"
                                      }])

         end
        end
     end
    end
  end
end
