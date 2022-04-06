# frozen_string_literal: true

module Login
  class MockUserSessionForm
    def persist
      id_attributes = load_mocks
      user_identity = UserIdentity.new(id_attributes)
      user = User.new(uuid: user_identity.attributes[:uuid])
      user.instance_variable_set(:@identity, user_identity)
      user.last_signed_in = Time.current.utc
      user.mhv_last_signed_in = Time.current.utc
      session = Session.new(
        uuid: user.uuid,
        ssoe_transactionid: "MOCKTXN-#{SecureRandom.uuid}"
      )
      session.save && user.save && user_identity.save
      [user, session]
    end

    def load_mocks
      mock_user_file = Settings.saml_ssoe.mock_user_file
      data = YAML.safe_load(File.read(mock_user_file)).deep_symbolize_keys!
      data[:user_identity]
    rescue => e
      Rails.logger.error "Failed to load mock user identity from #{mock_user_file}: #{e.message}", e
      raise
    end
  end
end
