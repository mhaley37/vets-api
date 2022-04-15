module Mobile
  module Auth
    class Session < Common::RedisStore
      redis_store REDIS_CONFIG[:mobile_session][:namespace]
      redis_ttl REDIS_CONFIG[:mobile_session][:each_ttl]
      redis_key :token
      
      attribute :token
      attribute :uuid
    end
  end
end
