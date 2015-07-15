class RailsLock
  DEFAULT_TIMEOUT = 60.seconds

  def self.synchronize(identifier)
    key = "#{identifier}_lock".to_sym
    while Rails.cache.read(key)
      sleep(rand)
    end
    Rails.cache.write(key, Time.now.utc.to_f, expires_in: DEFAULT_TIMEOUT)
    yield
  ensure
    Rails.cache.delete(key)
  end
end

class RedisLock
  DEFAULT_TIMEOUT = 60.seconds

  def self.synchronize(identifier)
    key = "#{identifier}_lock".to_sym
    while $redis.exists(key)
      sleep(rand)
    end
    $redis.set(key, Time.now.utc.to_f)
    $redis.expire(key, DEFAULT_TIMEOUT)
    yield
  ensure
    $redis.del(key)
  end
end

cache_lock_class = Rails.env.production? ? RedisLock : RailsLock
Object.const_set('CacheLock', cache_lock_class)
