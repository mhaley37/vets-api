# frozen_string_literal: true

class VeteranDeviceRecord < ApplicationRecord
  validates :user_uuid, :device_id, :active, presence: true
  belongs_to :device
end
