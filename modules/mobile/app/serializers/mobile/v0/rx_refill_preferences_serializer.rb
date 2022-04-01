# frozen_string_literal: true

module Mobile
  module V0
    class RxRefillPreferencesSerializer
      include FastJsonapi::ObjectSerializer

      set_type :preferences
      attributes :email_address,
                 :rx_flag
    end
  end
end
