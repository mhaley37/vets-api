# frozen_string_literal: true

class Device < ApplicationRecord
  validates :key, presence: true
  validates :key, uniqueness: true
  validates :name, presence: true
  has_many :veteran_device_records
end
