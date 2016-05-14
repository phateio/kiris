class ListenController < ApplicationController
  layout false

  def redirect
    icy_metadata = request.env['HTTP_ICY_METADATA']
    request_protocol = request.protocol # Returns 'https://' if this is an SSL request and 'http://' otherwise.

    if $ICECAST_SERVER
      stream_server = $ICECAST_SERVER
    elsif request.host != default_url_options.to_h[:host]
      stream_server = 'cdnstream.phate.io'
    # elsif icy_metadata.to_s == '1' || @useragent.to_s.downcase.include?('mobile')
    #   stream_server = 'stream.dallas.phate.io'
    else
      stream_server = 'stream.phate.io'
    end

    query_string = request.query_string
    location = "#{request_protocol}#{stream_server}/phatecc"
    location += '.mp3' if params[:format] == 'mp3'
    location += "?#{query_string}" if query_string.length > 0
    redirect_to location
  end
end
