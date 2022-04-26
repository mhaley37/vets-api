# frozen_string_literal: true

class Device < ApplicationRecord
  validates :name, uniqueness: true
  validates :name, presence: true
end
