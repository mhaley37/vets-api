# frozen_string_literal: true

module SignIn
  class Logger
    def info_log(message, attributes = {}, token = nil)
      attributes = attributes.merge(token_payload(token)) if token
      attributes[:timestamp] = Time.zone.now.to_s
      Rails.logger.info(message, attributes)
    end

    private

    def token_payload(token)
      token_type = token.class.to_s.include?('Refresh') ? 'refresh' : 'access'
      token_values = {
        token_type: token_type,
        user_id: token.user_uuid,
        session_id: token.session_handle
      }
      token_values[:access_token_id] = token.uuid if token_type == 'access'
      token_values
    end
  end
end
