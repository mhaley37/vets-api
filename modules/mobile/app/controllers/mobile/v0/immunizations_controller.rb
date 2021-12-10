# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class ImmunizationsController < ApplicationController
      def index
        json = service.get_immunizations
        data = Common::Collection.new(Immunization, data: json[:data])
        data.paginate(pagination_params)
        render json: Mobile::V0::ImmunizationSerializer.new(immunizations_adapter.parse(data))
      end

      private

      def immunizations_adapter
        Mobile::V0::Adapters::Immunizations.new
      end

      def service
        Mobile::V0::LighthouseHealth::Service.new(@current_user)
      end

      def pagination_params
        {
          # page: params[:page],
          per_page: 2
        }
      end
    end
  end
end
