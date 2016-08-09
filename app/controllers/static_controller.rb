class StaticController < ApplicationController
  layout false

  def robots
    if request.host == default_url_options.to_h[:host]
      file_name = 'robots.txt'
    else
      file_name = 'robots_disallow.txt'
    end
    render file_name, content_type: Mime::TEXT
  end

  def manifest
    raise ActionController::RoutingError.new('Not Found')
    render 'cache.appcache', content_type: 'text/cache-manifest'
  end

  def imgur_proxy
    imgur_id = params[:id]
    imgur_format = params[:format]
    imgur_url = "http://i.imgur.com/#{imgur_id}"
    imgur_url = "#{imgur_url}.#{imgur_format}" if imgur_format

    expires_in 1.month, public: true
    response = HTTParty.get(imgur_url, headers: headers)
    send_data response.body, status: response.code, type: response.content_type, disposition: 'inline'
  end
end
