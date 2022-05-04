# frozen_string_literal: true

module DhpConnectedDevices
  class VeteranDeviceRecordsController < ApplicationController

    def index
      veteran_device_records = VeteranDeviceRecord.active_devices(@current_user)
      active_devices = Device.where(id: veteran_device_records.map(&:device_id)).select(:key, :name)
      inactive_devices = Device.where.not(id: veteran_device_records.map(&:device_id)).select(:key, :name)
      render json: VeteranDeviceRecordSerializer.serialize(active_devices, inactive_devices)
    end
  end
end
