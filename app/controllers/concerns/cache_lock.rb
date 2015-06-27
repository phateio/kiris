class RailsLock
  DEFAULT_TIMEOUT = 60.seconds

  def self.synchronize(identifier)
    key = "#{identifier}_lock".to_sym
    while cache.read(key)
      sleep(rand)
    end
    cache.write(key, Time.now.utc.to_f, expires_in: DEFAULT_TIMEOUT)
    yield
  ensure
    cache.delete(key)
  end

  def self.cache
    Rails.cache
  end
end

class RedisLock
  DEFAULT_TIMEOUT = 60.seconds

  def self.synchronize(identifier)
    key = "#{identifier}_lock".to_sym
    while cache.read(key)
      sleep(rand)
    end
    cache.write(key, Time.now.utc.to_f, expires_in: DEFAULT_TIMEOUT)
    yield
  ensure
    cache.delete(key)
  end

  def self.cache
    Rails.cache
  end
end

cache_lock_class = Rails.env.production? ? RedisLock : RailsLock
Object.const_set('CacheLock', cache_lock_class)
