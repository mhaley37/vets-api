# frozen_string_literal: true

module SignIn
  module Logging
    class Token
      def log_token_creation(token)
        {
          audit_id: nil,
          session_id: token&.session_handle,
          user_id: token&.user_uuid,
          csp: nil,
          csp_id: nil,
          loa_ial: user.loa[:current],
          uri: nil,
          client_id: nil,
          access_token_hash: nil,
          refresh_token_hash: access_token&.refresh_token_hash,
          parent_refresh_token_hash: token&.parent_refresh_token_hash,
          created: token&.created_time ## just session?

        }
      end

      private

      def build_log_attributes(token)
        user = User.find(token&.user_uuid)
        {
          audit_id: nil,
          session_id: token&.session_handle,
          user_id: token&.user_uuid,
          csp: nil,
          csp_id: nil,
          loa_ial: user.loa[:current],
          uri: nil,
          client_id: nil,
          access_token_hash: nil,
          refresh_token_hash: access_token&.refresh_token_hash,
          parent_refresh_token_hash: token&.parent_refresh_token_hash,
          created: token&.created_time ## just session?

        }
      end
    end
  end
end
