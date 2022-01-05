# frozen_string_literal: true

require 'slack/service'

module SAML
  # This class is responsible for putting together a complete ruby-saml
  # SETTINGS object, meaning, our static SP settings + the IDP settings
  # loaded from a file
  module SSOeSettingsService
    class << self
      def saml_settings(options = {})
        settings = base_settings.dup
        options.each do |option, value|
          next if value.nil?

          settings.send("#{option}=", value)
        end
        settings
      end

      def base_settings
        base_settings = Settings.saml_ssoe.idp_metadata.dup

        if pki_needed?
          base_settings.certificate = Settings.saml_ssoe.certificate
          base_settings.private_key = Settings.saml_ssoe.key
          base_settings.certificate_new = Settings.saml_ssoe.certificate_new
        end
        base_settings.sp_entity_id = Settings.saml_ssoe.issuer
        base_settings.assertion_consumer_service_url = Settings.saml_ssoe.callback_url
        base_settings.compress_request = false

        base_settings.security[:authn_requests_signed] = Settings.saml_ssoe.request_signing
        base_settings.security[:want_assertions_signed] = Settings.saml_ssoe.response_signing
        base_settings.security[:want_assertions_encrypted] = Settings.saml_ssoe.response_encryption
        base_settings.security[:embed_sign] = false
        base_settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
        base_settings
      end

      def pki_needed?
        Settings.saml_ssoe.request_signing || Settings.saml_ssoe.response_encryption
      end

      def parse_idp_metadata
        parser = OneLogin::RubySaml::IdpMetadataParser.new
        settings_file = File.read(Settings.saml_ssoe.idp_metadata_file)
        settings_hash = parser.parse_to_hash(settings_file)
        settings_url = Settings.saml_ssoe.idp_metadata_url
        url_hash = parser.parse_remote_to_hash(settings_url)

        hash_diff = generate_saml_hash_diff(url_hash, settings_hash)
        if !url_hash.nil? && !hash_diff.empty?
          if %w[staging production].include? Settings.vsp_environment
            slack_text = build_saml_diff_slack_text(hash_diff)
            slack_service = Slack::Service.new(slack_text)
            slack_service.notify
          end
          parser.parse_remote(settings_url)
        else
          parser.parse(settings_file)
        end
      end

      def generate_saml_hash_diff(url_hash, settings_hash)
        hash_diff = {}
        url_hash.each_pair do |key, value|
          hash_diff[key] = value if value != settings_hash[key]
        end
        hash_diff
      end

      def build_saml_diff_slack_text(hash_diff)
        diff_string = ''
        hash_diff.each do |key, _value|
          diff_string += "• `#{key}`\n"
        end

        {
          header: 'ISAM SAML Metadata differences detected',
          text: [
            { block_type: 'section',
              text: "*ISAM SAML Metadata differences detected*\n" \
                    "Difference detected on: `#{Settings.vsp_environment}`\n" \
                    "Use <#{Settings.saml_ssoe.idp_metadata_url}|IAM's current metadata file> to update `vets-api`",
              text_type: 'mrkdwn' },
            { block_type: 'divider' },
            { block_type: 'section',
              text: "The following SAML attributes have been changed:\n#{diff_string}",
              text_type: 'mrkdwn' }
          ],
          channel: '#va-identity-alerts',
          webhook: Settings.saml_ssoe.va_identity_alerts_webhook
        }
      end
    end
  end
end
