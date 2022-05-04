# frozen_string_literal: true

module SignIn
  class Logger
    def info_log(message, attributes, token: nil)
      attributes = attributes.merge(token_payload(token)) if token
      Rails.logger.info(message, attributes)
    end

    private

    def token_payload(token)
      token_values = get_token_values(token)
      {
        token_type: token_values[:token_type],
        user_id: token.user_uuid,
        session_id: token.session_handle,
        access_token_id: token_values[:access_token_id],
        timestamp: Time.zone.now.to_s,
      }
    end

    def get_token_values(token)
      token_type = token.class.to_s.include?('Refresh') ? 'refresh' : 'access'
      refresh_token = token_type == 'refresh'
      {
        token_type: token_type,
        access_token_id: refresh_token ? nil : token.uuid,
      }
    end
  end
end
