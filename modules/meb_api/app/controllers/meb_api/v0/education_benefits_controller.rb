# frozen_string_literal: true

require 'dgi/eligibility/service'

module MebApi
  module V0
    class EducationBenefitsController < MebApi::V0::BaseController
      # disabling checks while we serve big mock JSON objects. Check will be reinstated when we integrate with DGIB
      # rubocop:disable Metrics/MethodLength
      def claimant_info
        render json:
          {
            data: {
              'id': '',
              'type': 'meb_api_dgi_automation_claimant_responses',
              'attributes': {
                'claimant': {
                  'claimantId': 1000000000000265,
                  'suffix': '',
                  'dateOfBirth': '1970-01-01',
                  'firstName': 'Andrea',
                  'lastName': 'Mitchell',
                  'middleName': '',
                  'notificationMethod': 'TEXT',
                  'contactInfo': {
                    'addressLine1': '123 Martin Luther King Blvd',
                    'addressLine2': '',
                    'city': 'New Orleans',
                    'zipcode': '70115',
                    'emailAddress': 'test@test.com',
                    'addressType': 'MILITARY_OVERSEAS',
                    'mobilePhoneNumber': '',
                    'homePhoneNumber': '',
                    'countryCode': 'US',
                    'stateCode': 'ME'
                  },
                  'preferredContact': ''
                },
                'serviceData': [
                  {
                    'branchOfService': 'Air Force',
                    'beginDate': '2010-01-01',
                    'endDate': '2020-01-01',
                    'characterOfService': 'Honorable',
                    'reasonForSeparation': 'Hardship',
                    'trainingPeriods': [{ 'beginDate': '2018-10-26T18:00:54.302Z', 'endDate': '2019-10-26T18:00:54.302Z' }],
                    'exclusionPeriods': [{ 'beginDate': '2012-10-26T18:00:54.302Z', 'endDate': '2013-10-26T18:00:54.302Z' }],
                  }
                ]
              }
            }
          }
      end
      # rubocop:enable all

      def service_history
        render json:
        { data: {
          'beginDate': '2010-10-26T18:00:54.302Z',
          'endDate': '2021-10-26T18:00:54.302Z',
          'branchOfService': 'ArmyActiveDuty',
          'trainingPeriods': [
            {
              'beginDate': '2018-10-26T18:00:54.302Z',
              'endDate': '2019-10-26T18:00:54.302Z'
            }
          ],
          'exclusionPeriods': [{ 'beginDate': '2012-10-26T18:00:54.302Z', 'endDate': '2013-10-26T18:00:54.302Z' }],
          'characterOfService': 'Honorable',
          'reasonForSeparation': 'ExpirationTimeOfService'
        } }
      end

      def eligibility
        response = eligibility_service.get_eligibility

        render json: response, serializer: EligibilitySerializer
      end

      def claim_status
        render json:
        { data: {
          'claimId': 0,
          'status': 'InProgress'
        } }
      end

      def submit_claim
        render json:
               { data: {
                 'status': 'received'
               } }
      end

      private

      def eligibility_service
        MebApi::DGI::Eligibility::Service.new @current_user
      end
    end
  end
end
