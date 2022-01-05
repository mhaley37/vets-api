# frozen_string_literal: true

require 'rails_helper'
require 'saml/ssoe_settings_service'
require 'lib/sentry_logging_spec_helper'

RSpec.describe SAML::SSOeSettingsService do
  before do
    allow(Settings).to receive(:vsp_environment).and_return(vsp_environment)
    allow(Settings.saml_ssoe).to receive(:idp_metadata_file).and_return(idp_metadata_file)
    allow(Settings.saml_ssoe).to receive(:idp_metadata_url).and_return(idp_metadata_url)
    allow(Settings.saml_ssoe).to receive(:va_identity_alerts_webhook).and_return(va_identity_alerts_webhook)
    allow(Settings.saml_ssoe).to receive(:request_signing).and_return(request_signing)
    allow(Settings.saml_ssoe).to receive(:response_signing).and_return(response_signing)
    allow(Settings.saml_ssoe).to receive(:response_encryption).and_return(response_encryption)
    allow(Settings.saml_ssoe).to receive(:certificate).and_return(certificate)
  end

  let(:vsp_environment) { 'staging' }
  let(:idp_metadata_file) { Rails.root.join('spec', 'support', 'saml', 'test_idp_metadata.xml') }
  let(:idp_metadata_url) { 'https://int.eauth.va.gov/isam/saml/metadata/saml20idp' }
  let(:va_identity_alerts_webhook) { 'https://hooks.slack.com/services/asdf1234' }
  let(:request_signing) { false }
  let(:response_signing) { false }
  let(:response_encryption) { false }
  let(:certificate) { 'foobar' }

  describe '.saml_settings' do
    it 'returns a settings instance' do
      expect(SAML::SSOeSettingsService.saml_settings).to be_an_instance_of(OneLogin::RubySaml::Settings)
    end

    it 'allows override of provided settings' do
      settings = SAML::SSOeSettingsService.saml_settings('sp_entity_id' => 'testIssuer')
      expect(settings.sp_entity_id).to equal('testIssuer')
    end

    context 'with no signing or encryption configured' do
      let(:expected_certificate) { nil }

      it 'omits certificate from settings' do
        expect(SAML::SSOeSettingsService.saml_settings.certificate).to eq(expected_certificate)
      end
    end

    context 'with signing configured' do
      let(:request_signing) { true }
      let(:expected_certificate) { 'foobar' }

      it 'includes certificate in settings' do
        expect(SAML::SSOeSettingsService.saml_settings.certificate).to eq(expected_certificate)
      end
    end

    context 'with encryption configured' do
      let(:response_encryption) { true }
      let(:expected_certificate) { 'foobar' }

      it 'includes certificate in settings' do
        expect(SAML::SSOeSettingsService.saml_settings.certificate).to eq(expected_certificate)
      end
    end
  end

  describe '.parse_idp_metadata' do
    context 'match between file & url metadata' do
      it 'returns parsed metadata from file' do
        VCR.use_cassette('saml/idp_int_metadata_isam', match_requests_on: %i[path query]) do
          allow_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse)
            .with(File.read(Settings.saml_ssoe.idp_metadata_file))
          expect_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse)
          SAML::SSOeSettingsService.parse_idp_metadata
        end
      end
    end

    context 'mismatch between file & url metadata' do
      it 'returns parsed metadata from url' do
        VCR.use_cassette('saml/updated_idp_int_metadata_isam',
                         allow_playback_repeats: true,
                         match_requests_on: %i[path query]) do
          VCR.use_cassette('slack/slack_bot_notify', match_requests_on: %i[path query]) do
            allow_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse_remote)
              .with(Settings.saml_ssoe.idp_metadata_url)
            expect_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse_remote)
            SAML::SSOeSettingsService.parse_idp_metadata
          end
        end
      end

      it 'notifies the #vsp-identity channel on Slack' do
        VCR.use_cassette('saml/updated_idp_int_metadata_isam',
                         allow_playback_repeats: true,
                         match_requests_on: %i[path query]) do
          VCR.use_cassette('slack/slack_bot_notify', match_requests_on: %i[path query]) do
            allow_any_instance_of(Slack::Service).to receive(:notify)
            expect_any_instance_of(Slack::Service).to receive(:notify)
            SAML::SSOeSettingsService.parse_idp_metadata
          end
        end
      end
    end
  end
end
