class ListenController < ApplicationController
  layout false

  def redirect
    useragent = @client[:useragent]
    icy_metadata = request.env['HTTP_ICY_METADATA']

    if $ICECAST_SERVER
      stream_server = $ICECAST_SERVER
    elsif request.host != default_url_options.to_h[:host]
      stream_server = 'stream-cdn.phate.io'
    elsif icy_metadata && icy_metadata == '1' || useragent.downcase.include?('mobile')
      stream_server = 'stream.rhc.phate.io'
    else
      stream_server = 'stream.phate.io'
    end
    stream_protocol = request.protocol

    query_string = request.query_string
    location = "#{stream_protocol}#{stream_server}/phatecc"
    location += '.mp3' if params[:format] == 'mp3'
    location += "?#{query_string}" if query_string.length > 0
    redirect_to location
  end
end
