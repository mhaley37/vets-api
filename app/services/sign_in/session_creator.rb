# frozen_string_literal: true

module SignIn
  class SessionCreator
    attr_reader :user_account

    def initialize(user_account:)
      @user_account = user_account
    end

    def perform
      SessionContainer.new(session: session,
                           refresh_token: refresh_token,
                           access_token: access_token,
                           anti_csrf_token: anti_csrf_token)
    end

    private

    def anti_csrf_token
      @anti_csrf_token ||= SecureRandom.hex
    end

    def refresh_token
      @refresh_token ||= create_new_refresh_token(parent_refresh_token_hash: parent_refresh_token_hash)
    end

    def access_token
      @access_token ||= create_new_access_token
    end

    def session
      @session ||= create_new_session
    end

    def double_parent_refresh_token_hash
      @double_parent_refresh_token_hash ||= get_hash(parent_refresh_token_hash)
    end

    def refresh_token_hash
      @refresh_token_hash ||= get_hash(refresh_token.to_json)
    end

    def parent_refresh_token_hash
      @parent_refresh_token_hash ||= get_hash(create_new_refresh_token.to_json)
    end

    def create_new_access_token
      new_access_token = SignIn::AccessToken.new(
        session_handle: handle,
        user_uuid: user_account.id,
        refresh_token_hash: refresh_token_hash,
        parent_refresh_token_hash: parent_refresh_token_hash,
        anti_csrf_token: anti_csrf_token,
        last_regeneration_time: refresh_created_time
      )
      log_token_creation(new_access_token)
      new_access_token
    end

    def create_new_refresh_token(parent_refresh_token_hash: nil)
      new_refresh_token = SignIn::RefreshToken.new(
        session_handle: handle,
        user_uuid: user_account.id,
        parent_refresh_token_hash: parent_refresh_token_hash,
        anti_csrf_token: anti_csrf_token
      )
      log_token_creation(new_refresh_token, parent_refresh_token_hash: parent_refresh_token_hash)
      new_refresh_token
    end

    def log_token_creation(token, parent_refresh_token_hash: nil)
      user = User.find(token&.user_uuid)
      user_csp = user.identity.sign_in[:service_name]
      token_type = token.class.to_s.include?('Refresh') ? 'refresh' : 'access'
      refresh_token_hash = token_type == 'Refresh' ? get_hash(token.to_json) : token&.refresh_token_hash

      token_log_info = {
        audit_id: SecureRandom.uuid,
        token_type: token_type,
        session_id: token&.session_handle,
        user_id: token&.user_uuid,
        csp: user_csp,
        csp_id: user_csp_id(user_csp, user),
        ial: user.loa[:current],
        access_token_hash: nil,
        refresh_token_hash: refresh_token_hash,
        parent_refresh_token_hash: parent_refresh_token_hash,
        created: refresh_created_time.to_time,
        event_type: 'create',
        event_outcome: token.valid? ? 'success' : 'failure'
      }
      Rails.logger.info('Sign in Service - Token created:', token_log_info)
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

    def create_new_session
      SignIn::OAuthSession.create!(user_account: user_account,
                                   handle: handle,
                                   hashed_refresh_token: double_parent_refresh_token_hash,
                                   refresh_expiration: refresh_expiration_time,
                                   refresh_creation: refresh_created_time)
    end

    def refresh_created_time
      @created_at ||= Time.zone.now
    end

    def refresh_expiration_time
      @expiration_at ||= Time.zone.now + Constants::RefreshToken::VALIDITY_LENGTH_MINUTES.minutes
    end

    def get_hash(object)
      Digest::SHA256.hexdigest(object)
    end

    def handle
      @handle ||= SecureRandom.uuid
    end

    def token_logger
      @token_logger ||= SignIn::Logging::Token.new
    end
  end
end
