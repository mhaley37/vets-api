# frozen_string_literal: true

class Device < ApplicationRecord
  validates :name, uniqueness: true
  validates :name, presence: true
  has_many :veteran_device_records
end
