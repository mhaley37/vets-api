# frozen_string_literal: true

require 'sign_in/logging'

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
      access_token = SignIn::AccessToken.new(
        session_handle: handle,
        user_uuid: user_account.id,
        refresh_token_hash: refresh_token_hash,
        parent_refresh_token_hash: parent_refresh_token_hash,
        anti_csrf_token: anti_csrf_token,
        last_regeneration_time: refresh_created_time
      )
      # log_token_creation(access_token)
      access_token
    end

    def create_new_refresh_token(parent_refresh_token_hash: nil)
      refresh_token = SignIn::RefreshToken.new(
        session_handle: handle,
        user_uuid: user_account.id,
        parent_refresh_token_hash: parent_refresh_token_hash,
        anti_csrf_token: anti_csrf_token
      )
      log_refresh_token_creation(refresh_token, parent_refresh_token_hash)
      refresh_token
    end

    def log_refresh_token_creation(token, parent_refresh_token_hash)
      user = User.find(token&.user_uuid)
      user_csp = user.identity.sign_in[:service_name]
      require 'pry'; binding.pry
      {
        audit_id: SecureRandom.uuid,
        session_id: token&.session_handle,
        user_id: token&.user_uuid,
        csp: user_csp,
        csp_id: user_csp_id(user_csp, user),
        loa_ial: user.loa[:current],
        uri: nil,
        client_id: nil,
        refresh_token_hash: get_hash(token.to_json),
        parent_refresh_token_hash: parent_refresh_token_hash,
        created: refresh_created_time.to_time,
        state: nil,
        event_type: 'create',
        event_outcome: nil,
        redirect_uri: nil,
        user_ip: nil,
        device_fingerprint: nil,
        token_start: nil
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
