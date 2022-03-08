# frozen_string_literal: true

module AuthnContext
  ID_ME = 'https://eauth.va.gov/csp?Select=idme3'
  LOGIN_GOV = 'https://eauth.va.gov/csp?Select=logingov3'

  CSP_METHODS = %w[DSL CAC DFAS DSL_SURROGATE CAC_SURROGATE DFAS_SURROGATE DSL_LOGINGOV
                   DSL_LOGINGOV_SURROGATE IDME IDME_DSL IDME_MHV IDME_VETS LOGINGOV MHV VACAC VAPIV VCSP]
  CSP_URL = 'https://eauth.va.gov/csp/'

  EXACT = 'exact'
  MINIMUM = 'minimum'
end
