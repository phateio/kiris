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
end
