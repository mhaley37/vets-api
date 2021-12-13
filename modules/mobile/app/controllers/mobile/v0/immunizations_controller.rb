# frozen_string_literal: true

require_dependency 'mobile/application_controller'

module Mobile
  module V0
    class ImmunizationsController < ApplicationController
      def index
        data = service.get_immunizations
        parsed = immunizations_adapter.parse(data)
        collection = Common::Collection.new(Immunization, data: parsed)
        paginated = collection.paginate(pagination_params)

        render json: Mobile::V0::ImmunizationSerializer.new(paginated.data)
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
          page: params[:page],
          per_page: params[:per_page]
        }
      end
    end
  end
end
