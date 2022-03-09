# frozen_string_literal: true

module AuthnContext
  ID_ME = 'https://eauth.va.gov/csp?Select=idme3'
  LOGIN_GOV = 'https://eauth.va.gov/csp?Select=logingov3'

  CSP_METHODS = %w[IDME LOGINGOV IDME_MHV IDME_DSL].freeze
  CSP_URL = 'https://eauth.va.gov/csp/'

  EXACT = 'exact'
  MINIMUM = 'minimum'
end
