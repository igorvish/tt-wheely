require 'active_support'
require 'active_support/cache'
require 'redis-store'
require "redis-activesupport"

RoutingService.configure do |config|
  config.cache = ActiveSupport::Cache.lookup_store :redis_store, { 
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
  }
end
