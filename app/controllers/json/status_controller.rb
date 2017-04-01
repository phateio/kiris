require 'cache_lock'

class Json::StatusController < ApplicationController
  layout false

  def index
    items = {}
    total_listeners = 0

    rails_cache_keys = Rails.cache.instance_variable_get(:@data).try(:keys) || []
    icecast_status_keys = rails_cache_keys.select do |key|
      key =~ /(?:\Aicecast_status|:icecast_status)\z/
    end

    icecast_status_keys.each do |icecast_status_key|
      icecast_status = Rails.cache.read(icecast_status_key)
      next unless icecast_status
      icecast_sources = icecast_status['icestats']['source']
      icecast_phateio_sources = Array(icecast_sources).select do |source|
        source['listenurl'] =~ %r{/phateio(?:\.\w+)?\z}
      end
      listeners = icecast_phateio_sources.map { |source| source['listeners'] }.inject(0, :+)
      total_listeners += listeners
    end
    items[:date] = Time.now.utc
    items[:listeners] = total_listeners * 10
    Rails.cache.write(:status, items, expires_in: 30.minutes)

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end
end
