# frozen_string_literal: true

require 'fakeredis/rspec'
require 'support/spec_builders'
require 'support/matchers'
require 'support/spool_helpers'
require 'support/fixture_helpers'
require 'support/silence_stream'
require 'sidekiq-pro' if Gem.loaded_specs.key?('sidekiq-pro')
require 'support/sidekiq/batch'
require 'support/stub_emis'
require 'support/okta_users_helpers'
require 'pundit/rspec'
require 'rspec/its'
require 'rspec/retry'

# By default run SimpleCov, but allow an environment variable to disable.
unless ENV['NOCOVERAGE']
  require 'simplecov'

  SimpleCov.start 'rails' do
    track_files '**/{app,lib}/**/*.rb'

    add_filter 'app/controllers/concerns/accountable.rb'
    add_filter 'app/models/in_progress_disability_compensation_form.rb'
    add_filter 'app/serializers/appeal_serializer.rb'
    add_filter 'config/initializers/clamscan.rb'
    add_filter 'lib/apps/configuration.rb'
    add_filter 'lib/apps/responses/response.rb'
    add_filter 'lib/config_helper.rb'
    add_filter 'lib/feature_flipper.rb'
    add_filter 'lib/gibft/configuration.rb'
    add_filter 'lib/ihub/appointments/response.rb'
    add_filter 'lib/salesforce/configuration.rb'
    add_filter 'lib/va_profile/address_validation/configuration.rb'
    add_filter 'lib/search/response.rb'
    add_filter 'lib/va_profile/exceptions/builder.rb'
    add_filter 'lib/va_profile/response.rb'
    add_filter 'modules/appeals_api/app/swagger'
    add_filter 'modules/apps_api/app/controllers/apps_api/docs/v0/api_controller.rb'
    add_filter 'modules/apps_api/app/swagger'
    add_filter 'modules/check_in/config/initializers/statsd.rb'
    add_filter 'modules/claims_api/app/controllers/claims_api/v0/forms/disability_compensation_controller.rb'
    add_filter 'modules/claims_api/app/controllers/claims_api/v1/forms/disability_compensation_controller.rb'
    add_filter 'modules/claims_api/app/swagger/*'
    add_filter 'modules/health_quest/lib/health_quest.rb'
    add_filter 'modules/health_quest/lib/health_quest/engine.rb'
    add_filter 'lib/bip_claims/configuration.rb'
    add_filter 'version.rb'

    # Modules
    add_group 'AppealsApi', 'modules/appeals_api/'
    add_group 'AppsApi', 'modules/apps_api'
    add_group 'CheckIn', 'modules/check_in/'
    add_group 'ClaimsApi', 'modules/claims_api/'
    add_group 'CovidResearch', 'modules/covid_research/'
    add_group 'CovidVaccine', 'modules/covid_vaccine/'
    add_group 'DhpConnectedDevices', 'modules/dhp_connected_devices/'
    add_group 'FacilitiesApi', 'modules/facilities_api/'
    add_group 'HealthQuest', 'modules/health_quest/'
    add_group 'Identity', 'modules/identity/'
    add_group 'LetsTryThisAgain', 'modules/lets_try_this_again/'
    add_group 'MebApi', 'modules/meb_api/'
    add_group 'Mobile', 'modules/mobile/'
    add_group 'MyHealth', 'modules/my_health/'
    add_group 'OpenidAuth', 'modules/openid_auth/'
    add_group 'Policies', 'app/policies'
    add_group 'Serializers', 'app/serializers'
    add_group 'Services', 'app/services'
    add_group 'Swagger', 'app/swagger'
    add_group 'TestUserDashboard', 'modules/test_user_dashboard/'
    add_group 'Uploaders', 'app/uploaders'
    add_group 'VaNotify', 'modules/va_notify/'
    add_group 'VAOS', 'modules/vaos/'
    add_group 'VAForms', 'modules/va_forms/'
    add_group 'VBADocuments', 'modules/vba_documents/'
    add_group 'Veteran', 'modules/veteran/'
    add_group 'VeteranVerification', 'modules/veteran_verification/'
    # End Modules

    if ENV['CI']
      SimpleCov.minimum_coverage 90
      SimpleCov.refuse_coverage_drop
    end
  end
  if ENV['TEST_ENV_NUMBER'] # parallel specs
    SimpleCov.at_exit do
      result = SimpleCov.result
      result.format! if ParallelTests.number_of_running_processes <= 1
    end
  end
end

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # fix for test rspec test randomization when using spring
  # https://github.com/rails/spring/issues/113#issuecomment-135896880
  config.seed = srand % 0xFFFF unless ARGV.any? { |arg| arg =~ /seed/ }
  config.order = :random
  Kernel.srand config.seed

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'tmp/specs.txt'

  config.default_retry_count = 3 if ENV['CI']

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    # Some specs stub out `YAML.load_file`, which I18n uses to load the
    # translation files. Because rspec runs things in random order, it's
    # possible that the YAML.load_file that's stubbed out for a spec
    # could actually be called by I18n if translations are required before
    # the functionality being tested. Once loaded, the translations stay
    # loaded, so we may as well take the hit and load them right away.
    # Verified working on --seed 11101, commit e378e8
    I18n.locale_available?(:en)
  end

  config.include SpecBuilders
  config.include SpoolHelpers
  config.include FixtureHelpers

  config.around(:example, :run_at) do |example|
    Timecop.freeze(Time.zone.parse(example.metadata[:run_at]))
    example.run
    Timecop.return
  end

  # enable `allow_forgery_protection` in Lighthouse specs to ensure that the endpoints
  # in those modules have explicitly skipped the CSRF protection functionality
  lighthouse_dirs = %r{
    modules/
    (appeals_api|apps_api|claims_api|openid_auth|va_forms|vba_documents|
      veteran|veteran_confirmation|veteran_verification)/
  }x
  config.define_derived_metadata(file_path: lighthouse_dirs) do |metadata|
    metadata[:enable_csrf_protection] = true
  end

  config.before(:all, :enable_csrf_protection) do
    @original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
  end

  config.after(:all, :enable_csrf_protection) do
    ActionController::Base.allow_forgery_protection = @original_allow_forgery_protection
  end
end
