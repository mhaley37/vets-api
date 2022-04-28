# frozen_string_literal: true

module DhpConnectedDevices
  class VeteranDeviceRecordController < ApplicationController
    # skip_before_action :authenticate

    def record
      render json: 'Record'
    end
  end
end
