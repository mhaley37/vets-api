# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimsApi::PoaFormBuilderJob, type: :job do
  subject { described_class }

  let(:power_of_attorney) { create(:power_of_attorney, :with_full_headers) }
  let(:poa_code) { 'ABC' }

  before do
    Sidekiq::Worker.clear_all
    b64_image = File.read('modules/claims_api/spec/fixtures/signature_b64.txt')
    power_of_attorney.form_data = {
      recordConcent: true,
      consentAddressChange: true,
      consentLimits: ['DRUG ABUSE', 'SICKLE CELL'],
      signatures: {
        veteran: b64_image,
        representative: b64_image
      },
      veteran: {
        serviceBranch: 'ARMY',
        address: {
          numberAndStreet: '2719 Hyperion Ave',
          city: 'Los Angeles',
          state: 'CA',
          country: 'US',
          zipFirstFive: '92264'
        },
        phone: {
          areaCode: '555',
          phoneNumber: '5551337'
        }
      },
      claimant: {
        firstName: 'Lillian',
        middleInitial: 'A',
        lastName: 'Disney',
        email: 'lillian@disney.com',
        relationship: 'Spouse',
        address: {
          numberAndStreet: '2688 S Camino Real',
          city: 'Palm Springs',
          state: 'CA',
          country: 'US',
          zipFirstFive: '92264'
        },
        phone: {
          areaCode: '555',
          phoneNumber: '5551337'
        }
      },
      serviceOrganization: {
        poaCode: poa_code.to_s,
        organizationName: 'I Help Vets LLC',
        address: {
          numberAndStreet: '2719 Hyperion Ave',
          city: 'Los Angeles',
          state: 'CA',
          country: 'US',
          zipFirstFive: '92264'
        }
      }
    }
    power_of_attorney.save
  end

  describe 'generating the filled and signed pdf' do
    context 'when representative is an individual' do
      before do
        Veteran::Service::Representative.new(representative_id: '12345', poa_codes: [poa_code.to_s]).save!
      end

      it 'generates the pdf to match example' do
        expect(ClaimsApi::PoaPdfConstructor::Individual).to receive(:new).and_call_original
        expect_any_instance_of(ClaimsApi::PoaPdfConstructor::Individual).to receive(:construct).and_call_original
        subject.new.perform(power_of_attorney.id)
      end

      it 'Calls the POA updater job upon successful upload to VBMS' do
        token_response = OpenStruct.new(upload_token: '<{573F054F-E9F7-4BF2-8C66-D43ADA5C62E7}')
        document_response = OpenStruct.new(upload_document_response: {
          '@new_document_version_ref_id' => '{52300B69-1D6E-43B2-8BEB-67A7C55346A2}',
          '@document_series_ref_id' => '{A57EF6CC-2236-467A-BA4F-1FA1EFD4B374}'
        }.with_indifferent_access)

        allow_any_instance_of(ClaimsApi::VBMSUploader).to receive(:fetch_upload_token).and_return(token_response)
        allow_any_instance_of(ClaimsApi::VBMSUploader).to receive(:upload_document).and_return(document_response)

        expect(ClaimsApi::PoaUpdater).to receive(:perform_async)

        subject.new.perform(power_of_attorney.id)
      end
    end

    context 'when representative is part of an organization' do
      before do
        Veteran::Service::Representative.new(representative_id: '67890', poa_codes: [poa_code.to_s]).save!
        Veteran::Service::Organization.create(poa: 'ABC', name: 'Some org')
      end

      it 'generates the pdf to match example' do
        expect(ClaimsApi::PoaPdfConstructor::Organization).to receive(:new).and_call_original
        expect_any_instance_of(ClaimsApi::PoaPdfConstructor::Organization).to receive(:construct).and_call_original
        subject.new.perform(power_of_attorney.id)
      end

      it 'Calls the POA updater job upon successful upload to VBMS' do
        token_response = OpenStruct.new(upload_token: '<{573F054F-E9F7-4BF2-8C66-D43ADA5C62E7}')
        document_response = OpenStruct.new(upload_document_response: {
          '@new_document_version_ref_id' => '{52300B69-1D6E-43B2-8BEB-67A7C55346A2}',
          '@document_series_ref_id' => '{A57EF6CC-2236-467A-BA4F-1FA1EFD4B374}'
        }.with_indifferent_access)

        allow_any_instance_of(ClaimsApi::VBMSUploader).to receive(:fetch_upload_token).and_return(token_response)
        allow_any_instance_of(ClaimsApi::VBMSUploader).to receive(:upload_document).and_return(document_response)

        expect(ClaimsApi::PoaUpdater).to receive(:perform_async)

        subject.new.perform(power_of_attorney.id)
      end
    end
  end
end
