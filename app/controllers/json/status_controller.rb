require 'cache_lock'

class Json::StatusController < ApplicationController
  layout false

  def index
    items = {}

    icecast_status = Rails.cache.read('icecast_status')
    if icecast_status
      icecast_sources = icecast_status['icestats']['source']
      listeners = Array(icecast_sources).map { |source| source['listeners'] }.inject(0, :+)
      items[:date] = Time.now.utc
      items[:listeners] = listeners
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end
end
