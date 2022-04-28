# frozen_string_literal: true

module Mobile
  class TestSessionHelper
    REDIS_NAMESPACE = 'mobile_staging_test_session'

    def initialize(access_token)
      @access_token = access_token
    end

    def find_or_create_session_token
      decoded_token = JWT.decode(@access_token, Settings.mobile_api.test_session_secret, true, { algorithm: 'HS256' })

      identity_args = decoded_token.first
      token = redis.get(identity_args['uuid'])
      return token if token

      create_background_session(identity_args)
    end

    private

    def create_background_session(identity_args)
      identity = IAMUserIdentity.new(identity_args.deep_symbolize_keys)
      identity.save

      user = IAMUser.build_from_user_identity(identity)
      user.save

      test_token = SecureRandom.alphanumeric
      session = IAMSession.new(token: test_token, uuid: identity.uuid)
      session.save

      redis.set(identity_args['uuid'], test_token)
      @redis.expire(identity_args['uuid'], identity_args['expiration_timestamp'])
      test_token
    end

    def redis
      @redis ||= Redis::Namespace.new(REDIS_NAMESPACE, redis: $redis)
    end
  end
end
