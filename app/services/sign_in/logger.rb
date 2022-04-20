# frozen_string_literal: true

module SignIn
  class Logger
    def log_token(token, event: 'create', parent_refresh_token_hash: nil, outcome: 'success')
      user = User.find(token&.user_uuid)
      user_csp = user.identity.sign_in[:service_name]
      token_type = token.class.to_s.include?('Refresh') ? 'refresh' : 'access'
      if token_type == 'refresh'
        refresh_token_hash = Digest::SHA256.hexdigest(token.to_json)
        access_token_hash = nil
      else
        refresh_token_hash = token&.refresh_token_hash
        access_token_hash = Digest::SHA256.hexdigest(token.to_json)
      end

      token_log_info = {
        audit_id: SecureRandom.uuid,
        token_type: token_type,
        session_id: token&.session_handle,
        user_id: token&.user_uuid,
        csp: user_csp,
        csp_id: user_csp_id(user_csp, user),
        ial: user.loa[:current],
        refresh_token_hash: refresh_token_hash,
        access_token_hash: access_token_hash,
        parent_refresh_token_hash: parent_refresh_token_hash,
        timestamp: Time.zone.now.to_s,
        event: event,
        event_outcome: outcome
      }
      Rails.logger.info("Sign in Service Token - #{event}:", token_log_info)
    end

    def log_session_refresh(refresh_token)
      token_log_info = {
        session_id: refresh_token&.session_handle,
        refresh_token_hash: Digest::SHA256.hexdigest(refresh_token.to_json),
        parent_refresh_token_hash: refresh_token&.parent_refresh_token_hash,
        user_id: refresh_token&.user_uuid,
        timestamp: Time.zone.now.to_s,
        event: 'refresh',
        event_outcome: 'success'
      }
      require 'pry'; binding.pry
      Rails.logger.info('Sign in Service - Session refreshed:', token_log_info)
    end

    private

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
