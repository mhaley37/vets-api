# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class ImmunizationsController < ApplicationController
      def index
        data = service.get_immunizations
        parsed = immunizations_adapter.parse(data)
        # data = Mobile::V0::ImmunizationSerializer.new(parsed)
        collection = Common::Collection.new(Immunization, data: parsed)

        render json: collection.paginate(pagination_params)
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
