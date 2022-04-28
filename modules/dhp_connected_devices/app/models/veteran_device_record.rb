# frozen_string_literal: true

class VeteranDeviceRecord < ApplicationRecord
  validates :user_uuid, :device_id, :active, presence: true
  belongs_to :device
  before_validation :validate_unique_ids, on: :create

  def self.active_devices(current_user)
    VeteranDeviceRecord.where(user_uuid: current_user.uuid, active: true)
  end

  def validate_unique_ids
    if VeteranDeviceRecord.find_by(device_id: device_id, user_uuid: user_uuid).nil?
      nil
    else
      errors.add(:user_uuid, 'user_uuid already associated with provided device_id')
      errors.add(:device_id, 'device_id already associated with provided user_uuid')
    end
  end
end
