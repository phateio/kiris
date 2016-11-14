require 'cache_lock'

class Json::StatusController < ApplicationController
  layout false

  def index
    items = {}

    CacheLock.synchronize(:status) do
      items = Rails.cache.fetch(:status, expires_in: 60.seconds) do
        total_listeners = 0
        servers = $ICECAST_RELAYS.to_s.split(',')
        servers.each do |server|
          res_body = http_get_response_body("http://#{server}/status-json.xsl") rescue nil
          next if res_body.nil?
          icecast_status = JSON.parse(res_body)
          icecast_sources = icecast_status['icestats']['source']
          listeners = Array(icecast_sources).map { |source| source['listeners'] }.inject(0, :+)
          total_listeners += listeners
        end
        items[:date] = Time.now.utc
        items[:listeners] = total_listeners
        items
      end
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end
end
