# frozen_string_literal: true

require 'rails_helper'

describe LgyService do
  describe '#new' do
    let(:user) { create :user }
    subject { described_class.new(edipi: user.edipi, icn: user.icn) }
    it 'creates a new object of type LgyService' do
      expect(subject).to be_instance_of(LgyService)
    end
  end
end
