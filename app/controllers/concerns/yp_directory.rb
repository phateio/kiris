require 'net/http'

class YPDirectory
  attr_reader :yp_url
  attr_reader :yp_sid_key
  attr_reader :sid

  def http_request(uri, req)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 1
    http.read_timeout = 1
    http.request(req)
  end

  def initialize(yp_url)
    yp_unique = Zlib::crc32(yp_url).to_s(16).rjust(8, '0')
    @yp_url = yp_url
    @yp_sid_key = "yp_#{yp_unique}_sid".to_sym
    @sid ||= Rails.cache.read(@yp_sid_key)
  end

  def add(params)
    params.merge!(action: 'add')
    uri = URI.parse(@yp_url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(params)
    res = http_request(uri, req)
    @sid = res['SID']
    Rails.cache.write(@yp_sid_key, @sid)
  end

  def touch(params)
    params.merge!(action: 'touch', sid: @sid)
    uri = URI.parse(@yp_url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(params)
    res = http_request(uri, req)
    reset if res['YPMessage'].include?('SID does not exist')
  end

  def remove
    params.merge!(action: 'remove', sid: @sid)
    uri = URI.parse(@yp_url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(params)
    res = http_request(uri, req)
    reset
  end

  def reset
    Rails.cache.delete(@yp_sid_key)
    @sid = nil
  end

  def connected?
    @sid.to_s.present?
  end
end
