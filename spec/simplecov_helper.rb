# frozen_string_literal: true

# spec/simplecov_helper.rb
require 'active_support/inflector'
require 'simplecov'

class SimpleCovHelper
  def self.report_coverage(base_dir: './coverage_results')
    SimpleCov.start 'rails' do
      skip_check_coverage = ENV.fetch('SKIP_COVERAGE_CHECK', 'false')

      track_files '**/{app,lib}/**/*.rb'

      add_filters
      add_modules

      minimum_coverage(90) unless skip_check_coverage
      refuse_coverage_drop unless skip_check_coverage
      merge_timeout(3600)
    end
    new(base_dir: base_dir).merge_results
  end

  attr_reader :base_dir

  def initialize(base_dir:)
    @base_dir = base_dir
  end

  def all_results
    Dir["#{base_dir}/.resultset*.json"]
  end

  def merge_results
    SimpleCov.collate all_results
  rescue RuntimeError
    nil
  end

  def self.add_filters
    add_filter 'app/controllers/concerns/accountable.rb'
    add_filter 'config/initializers/clamscan.rb'
    add_filter 'lib/apps/configuration.rb'
    add_filter 'lib/apps/responses/response.rb'
    add_filter 'lib/config_helper.rb'
    add_filter 'lib/feature_flipper.rb'
    add_filter 'lib/gibft/configuration.rb'
    add_filter 'lib/ihub/appointments/response.rb'
    add_filter 'lib/salesforce/configuration.rb'
    add_filter 'lib/vet360/address_validation/configuration.rb'
    add_filter 'lib/search/response.rb'
    add_filter 'lib/vet360/exceptions/builder.rb'
    add_filter 'lib/vet360/response.rb'
    add_filter 'modules/claims_api/app/controllers/claims_api/v0/forms/disability_compensation_controller.rb'
    add_filter 'modules/claims_api/app/controllers/claims_api/v1/forms/disability_compensation_controller.rb'
    add_filter 'modules/claims_api/app/swagger/*'
    add_filter 'lib/bip_claims/configuration.rb'
    add_filter 'version.rb'
  end

  def self.add_modules
    # Modules
    add_group 'AppealsApi', 'modules/appeals_api/'
    add_group 'CheckIn', 'modules/check_in/'
    add_group 'ClaimsApi', 'modules/claims_api/'
    add_group 'CovidVaccine', 'modules/covid_vaccine/'
    add_group 'FacilitiesApi', 'modules/facilities_api/'
    add_group 'HealthQuest', 'modules/health_quest'
    add_group 'Identity', 'modules/identity/'
    add_group 'MebApi', 'modules/meb_api/'
    add_group 'Notify', 'modules/notify/'
    add_group 'OpenidAuth', 'modules/openid_auth/'
    add_group 'Policies', 'app/policies'
    add_group 'Serializers', 'app/serializers'
    add_group 'Services', 'app/services'
    add_group 'Swagger', 'app/swagger'
    add_group 'TestUserDashboard', 'modules/test_user_dashboard/'
    add_group 'Uploaders', 'app/uploaders'
    add_group 'VAOS', 'modules/vaos/'
    add_group 'VBADocuments', 'modules/vba_documents/'
    add_group 'Veteran', 'modules/veteran/'
    add_group 'VeteranVerification', 'modules/veteran_verification/'
  end
end
