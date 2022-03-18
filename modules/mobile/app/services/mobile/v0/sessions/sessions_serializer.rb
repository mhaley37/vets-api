# frozen_string_literal: true

module Mobile
  module V0
    module Sessions
      class SessionsSerializer
        def initialize(_arg)
          @sessions = []
          @redis = Redis.current
        end

        def generate_sessions
          sessions = @sessions.map do |session|
            {
              uuid: session.uuid
            }
          end
          JSON.pretty_generate(sessions)
        end

        private

        def add
          raise 'subclass must implement #add'
        end

        def save_session(uuid = nil)
          uuid ||= SecureRandom.uuid.delete('-')
          token = SecureRandom.uuid.delete('-')
          session = Session.new(token: token, uuid: uuid)
          session.save
          @sessions << session
          uuid
        end

        def redis_set(uuid, user, mvi_profile, identity)
binding.pry
          @redis.set "users_b:#{uuid}", user.to_json
          @redis.set "mvi-profile-response:#{uuid}", mvi_profile.to_json
          @redis.set "user_identities:#{uuid}", identity.to_json
        end
      end
    end
  end
end