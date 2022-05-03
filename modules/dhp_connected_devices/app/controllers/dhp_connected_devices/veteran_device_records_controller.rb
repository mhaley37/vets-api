# frozen_string_literal: true

module DhpConnectedDevices
  class VeteranDeviceRecordsController < ApplicationController

    def index
      active_devices = VeteranDeviceRecord.active_devices(@current_user)
      inactive_devices = Device.where.not(id: active_devices.map(&:device_id))
      render json: VeteranDeviceRecordSerializer.serialize(active_devices, inactive_devices)
    end
  end
end
