# frozen_string_literal: true

module Login
  class MockUserSessionForm
    def persist(icn)
      id_attributes = user_identity(icn)
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

    private

    def uuid
      @uuid ||= SecureRandom.hex
    end

    def ssn
      '796126859'
    end

    def birth_date
      '19320205'
    end

    def email
      'vets.gov.user+0@gmail.com'
    end

    def authn_context
      'http://idmanagement.gov/ns/assurance/loa/3'
    end

    def first_name
      'Hector'
    end

    def last_name
      'Allen'
    end

    def gender
      'M'
    end

    def loa
      3
    end

    def service_name
      'idme'
    end

    def user_identity(icn = '1012667122V019349')
      {
        uuid: uuid,
        email: email,
        first_name: first_name,
        last_name: last_name,
        gender: gender,
        birth_date: birth_date,
        icn: icn,
        ssn: ssn,
        loa: { current: loa, highest: loa },
        authn_context: authn_context,
        idme_uuid: uuid,
        mhv_icn: icn,
        sign_in: { service_name: service_name, account_type: 'N/A' }
      }
    end
  end
end
