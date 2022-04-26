# frozen_string_literal: true

module SignIn
  class Logger
    def log_token(token, event: 'create', parent_refresh_token_hash: nil, outcome: 'success')
      user_values = get_user_csp_values(token.user_uuid)
      token_values = get_token_values(token)
      token_log_payload = {
        access_token_id: token_values[:access_token_id],
        token_type: token_values[:token_type],
        session_id: token.session_handle,
        user_id: token.user_uuid,
        csp: user_values[:user_csp],
        csp_id: user_values[:user_csp_id],
        ial: user_values[:ial],
        refresh_token_hash: token_values[:refresh_token_hash],
        access_token_hash: token_values[:access_token_hash],
        parent_refresh_token_hash: parent_refresh_token_hash,
        timestamp: Time.zone.now.to_s,
        event: event,
        event_outcome: outcome
      }
      Rails.logger.info("Sign in Service Token - #{event}:", token_log_payload)
    end

    private

    def get_user_csp_values(user_uuid)
      user = User.find(user_uuid)
      user_csp = user.identity.sign_in[:service_name]
      {
        user_csp: user_csp,
        user_csp_id: user_csp_id(user_csp, user),
        ial: user.loa[:current]
      }
    end

    def get_token_values(token)
      token_type = token.class.to_s.include?('Refresh') ? 'refresh' : 'access'
      refresh_token = token_type == 'refresh'
      {
        token_type: token_type,
        refresh_token_hash: refresh_token ? Digest::SHA256.hexdigest(token.to_json) : token.refresh_token_hash,
        access_token_id: refresh_token ? nil : token.uuid,
        access_token_hash: refresh_token ? nil : Digest::SHA256.hexdigest(token.to_json)
      }
    end

    def user_csp_id(user_csp, user)
      case user_csp
      when 'logingov'
        user.logingov_uuid
      when 'dslogon'
        user.edipi
      when 'mhv'
        user.icn
      when 'idme'
        user.idme_uuid
      end
    end
  end
end
