# frozen_string_literal: true

module SignIn
  class RefreshToken
    include ActiveModel::Validations

    attr_reader :user_uuid, :session_handle, :parent_refresh_token_hash, :anti_csrf_token, :nonce, :version

    validates :user_uuid, :session_handle, :anti_csrf_token, :nonce, :version, presence: true
    validates :version, inclusion: SignIn::Constants::RefreshToken::VERSION_LIST

    # rubocop:disable Metrics/ParameterLists
    def initialize(session_handle:,
                   user_uuid:,
                   anti_csrf_token:,
                   parent_refresh_token_hash: nil,
                   nonce: create_nonce,
                   version: SignIn::Constants::RefreshToken::CURRENT_VERSION)
      @user_uuid = user_uuid
      @session_handle = session_handle
      @parent_refresh_token_hash = parent_refresh_token_hash
      @anti_csrf_token = anti_csrf_token
      @nonce = nonce
      @version = version

      validate!
    end
    # rubocop:enable Metrics/ParameterLists

    def persisted?
      false
    end

    private

    def create_nonce
      SecureRandom.hex
    end
  end
end
