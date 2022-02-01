# frozen_string_literal: true

module CheckIn
  module V2
    class SessionsController < CheckIn::ApplicationController
      before_action :before_logger, only: %i[show create], if: :additional_logging?
      after_action :after_logger, only: %i[show create], if: :additional_logging?

      def show
        check_in_session = CheckIn::V2::Session.build(data: { uuid: params[:id] }, jwt: session[:jwt])

        render json: check_in_session.client_error, status: :ok and return unless check_in_session.valid_uuid?
        render json: check_in_session.unauthorized_message, status: :ok and return unless check_in_session.authorized?

        render json: check_in_session.success_message
      end

      def create
        check_in_session = CheckIn::V2::Session.build(data: permitted_params, jwt: session[:jwt])

        render json: check_in_session.client_error, status: :bad_request and return unless check_in_session.valid?
        render json: check_in_session.success_message and return if check_in_session.authorized?

        token_data = ::V2::Lorota::Service.build(check_in: check_in_session).token

        session[:jwt] = token_data[:jwt]

        render json: token_data[:permission_data]
      end

      def permitted_params
        params.require(:session).permit(:uuid, :last4, :last_name)
      end

      private

      def authorize
        routing_error unless Flipper.enabled?('check_in_experience_enabled')
      end
    end
  end
end
