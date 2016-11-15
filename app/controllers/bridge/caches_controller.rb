class Bridge::CachesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    secret_key = request.POST[:secret_key]
    if secret_key != $BRIDGE_SECRET_KEY
      render text: '403 Forbidden', status: :forbidden
      return
    end

    key = request.POST[:key]
    value = JSON.parse(request.POST[:value], quirks_mode: true)
    expires = request.POST[:expires] || 1.hour
    return_value = Rails.cache.write(key, value, expires_in: expires)

    respond_to do |format|
      # format.xml { render xml: return_value }
      format.json { render json: return_value }
      format.any { head :not_found }
    end
  end
end
