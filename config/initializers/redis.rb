$redis = Redis.new(url: ENV['REDIS_URL']) if Rails.env.production?
