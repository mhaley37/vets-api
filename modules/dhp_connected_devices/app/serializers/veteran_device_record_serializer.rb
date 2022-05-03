# frozen_string_literal: true

class VeteranDeviceRecordSerializer
  def self.serialize(device_records, inactive_devices)
    active_devices = Device.where(id: device_records.map(&:device_id)).select(:key, :name)
    {
      devices:
        active_devices
          .map { |device| device.as_json(:except => :id).merge({ authUrl: "/#{device.key}", disconnectUrl: "/#{device.key}/disconnect", connected: true }) } +
          inactive_devices.select(:key, :name)
                          .map { |device| device.as_json(:except => :id).merge({ authUrl: "/#{device.key}", disconnectUrl: "/#{device.key}/disconnect", connected: false }) }
    }
  end
end
