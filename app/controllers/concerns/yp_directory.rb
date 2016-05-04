require 'zlib'
require 'httparty'

class YPDirectory
  attr_reader :yp_url
  attr_reader :yp_sid_key
  attr_reader :sid

  def initialize(yp_url)
    yp_unique = Zlib.crc32(yp_url).to_s(16).rjust(8, '0')
    @yp_url = yp_url
    @yp_sid_key = "yp_#{yp_unique}_sid".to_sym
    @sid ||= Rails.cache.read(@yp_sid_key)
  end

  def add(params = {})
    params[:action] = 'add'
    response = HTTParty.post(@yp_url, query: params)
    @sid = response.headers['SID']
    Rails.cache.write(@yp_sid_key, @sid)
  end

  def touch(params = {})
    params[:action] = 'touch'
    params[:sid] = @sid
    response = HTTParty.post(@yp_url, query: params)
    reset if response.headers['YPMessage'].include?('SID does not exist')
  end

  def remove(params = {})
    params[:action] = 'remove'
    params[:sid] = @sid
    HTTParty.post(@yp_url, query: params)
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
