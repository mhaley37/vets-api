# frozen_string_literal: true

class VeteranDeviceRecordSerializer
  def self.serialize(data)
    {
      devices: Device.where(id: data.map(&:device_id)).pluck(:name)
    }
  end
end
