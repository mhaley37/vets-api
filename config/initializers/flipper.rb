# frozen_string_literal: true

require 'flipper'
require 'flipper/adapters/active_record'
require 'active_support/cache'
require 'flipper/adapters/redis_cache'
require 'flipper/action_patch'
require 'flipper/configuration_patch'
require 'flipper/instrumentation/event_subscriber'

FLIPPER_FEATURE_CONFIG = YAML.safe_load(File.read(Rails.root.join('config', 'features.yml')))
FLIPPER_ACTOR_USER = 'user'
FLIPPER_ACTOR_STRING = 'cookie_id'

##
# Flipper configuration
#
Flipper.configure do |config|
  config.default do
    activerecord_adapter = Flipper::Adapters::ActiveRecord.new

    if Rails.env.development? || %w[development sandbox staging].include?(Settings.vsp_environment)
      redis_cache = Flipper::Adapters::RedisCache.new(activerecord_adapter, Redis.current, 360)
      instrumented = Flipper::Adapters::Instrumented.new(redis_cache, instrumenter: ActiveSupport::Notifications)
    elsif Rails.env.test?
      instrumented =
        Flipper::Adapters::Instrumented.new(activerecord_adapter, instrumenter: ActiveSupport::Notifications)
    else
      cache = ActiveSupport::Cache::MemoryStore.new
      cached_adapter = Flipper::Adapters::ActiveSupportCacheStore.new(activerecord_adapter, cache, expires_in: 1.minute)
      instrumented = Flipper::Adapters::Instrumented.new(cached_adapter, instrumenter: ActiveSupport::Notifications)
    end

    Flipper.new(instrumented, instrumenter: ActiveSupport::Notifications)
  end
end

# Make sure that each feature we reference in code is present in the UI, as long as we have a Database already
begin
  FLIPPER_FEATURE_CONFIG['features'].each do |feature, feature_config|
    unless Flipper.exist?(feature)
      Flipper.add(feature)

      # default features to enabled for test and those explicitly set for development
      Flipper.enable(feature) if Rails.env.test? || (Rails.env.development? && feature_config['enable_in_development'])
    end
  end
  # remove features from UI that have been removed from code
  removed_features = (Flipper.features.collect(&:name) - FLIPPER_FEATURE_CONFIG['features'].keys)
  removed_features.each { |feature_name| Flipper.remove(feature_name) }
rescue
  # make sure we can still run rake tasks before table has been created
  nil
end

# A contrived example of how we might use a "group"
# (a method that can be evaluated at runtime to determine feature status)
#
# Flipper.register(:first_name_is_hector) do |user|
#   user.respond_to?(:first_name) && user.first_name == 'HECTOR'
# end

Flipper::UI.configuration.feature_creation_enabled = false
# Modify Flipper::UI::Action to use custom views if they exist
# and to add descriptions and types for features.
Flipper::UI::Action.prepend(FlipperExtensions::ActionPatch)
# Modify Flipper::UI::Configuration to accept a custom view path.
Flipper::UI::Configuration.prepend(FlipperExtensions::ConfigurationPatch)
Flipper::UI.configure do |config|
  config.custom_views_path = Rails.root.join('lib', 'flipper', 'views')
end
