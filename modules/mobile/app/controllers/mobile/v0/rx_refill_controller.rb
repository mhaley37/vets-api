# frozen_string_literal: true

require 'rx/client'

module Mobile
  module V0
    class RxRefillController < ApplicationController
      include Filterable

      before_action { authorize :mhv_prescriptions, :access? }

      # @param refill_status - one refill status to filter on
      # @param page - the paginated page to fetch
      # @param per_page - the number of items to fetch per page
      # @param sort - the attribute to sort on, negated for descending
      #        (ie: ?sort=facility_name,-prescription_id)
      def get_history
        binding.pry
        resource = collection_resource
        resource =  Mobile::V0::RxHistory.new(rx_history: resource)
        resource = params[:filter].present? ? resource.find_by(filter_params) : resource
        resource = resource.sort(params[:sort])
        resource = resource.paginate({ page: params[:page], per_page: params[:per_page] })

        render json: Mobile::V0::RxRefillHistorySerializer.new(@current_user.id, resource)
      end

      private

      def client
        @client ||= Rx::Client.new(session: { user_id: @current_user.mhv_correlation_id })
      end

      def rx_history_adapter
        Mobile::V0::Adapters::RxHistory.new
      end

      def collection_resource
        case params[:refill_status]
        when 'active'
          client.get_active_rxs
        else
          client.get_history_rxs
        end
      end
    end
  end
end
