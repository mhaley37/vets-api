# frozen_string_literal: true

module DhpConnectedDevices
  class VeteranDeviceRecordController < ApplicationController
    # skip_before_action :authenticate

    def index
      render json: VeteranDeviceRecordSerializer.serialize(VeteranDeviceRecord.active_devices(current_user))
    end
  end
end
