# frozen_string_literal: true

module Mobile
  module Auth
    class SessionManager
      def initialize(access_token)
        @access_token = access_token
      end

      def find_or_create
        user = User.find(access_token.user_uuid)
        session = Session.find(@access_token)
        return session.user_uuid if session

        user_uuid = introspect_user_by_token
        create_session(user_uuid)
      end

      private

      def introspect_user_by_token
        response = Service.new.post_introspect(@access_token)
        response.dig('data', 'attributes', 'uuid')
      end

      def create_session(user_uuid)
        session = Session.new(token: access_token, uuid: user_uuid)
        session.save!
        Rails.logger.info('mobile session: creation success', user_uuid: @current_user.uuid)
        session
      rescue => e
        Rails.logger.error('mobile session: creation failure', error: e.message)
        raise e
      end
    end
  end
end
