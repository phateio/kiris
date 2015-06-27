require 'cache_lock'
require 'net/http'
require 'ipaddr'
require 'uri'
require 'resolv'

class Json::RequestController < ApplicationController
  layout false

  def create
    items = {}

    track_id = request.POST[:track_id]
    nickname = request.POST[:nickname].to_s.strip
    userip = @client[:ip]
    referer = @client[:referer]
    useragent = @client[:useragent]
    forwarded_ips = @client[:forwarded_ips]
    forwarded_for = @client[:forwarded_ips].last(3).join(', ')
    forwarded_str = @client[:forwarded_ips].last(3).map {|ip| "'#{ip}'"}.join(', ')
    server_addr = @client[:server_addr]
    server_port = @client[:server_port]
    cookie_ips = session[:forwarded_for].to_s.split(/\s*,\s*/)
    user_ipaddr = IPAddr.new(userip)
    masked_addr = user_ipaddr.mask(user_ipaddr.ipv4? ? '255.255.0.0' : 112).to_s

    client_ips = forwarded_ips
    client_ips << userip
    client_ips += cookie_ips if cookie_ips.present?
    client_ips.uniq!

    track = Track.find(track_id)

    begin
      if track.nil?
        items[:message] = I18n.t('search.request_msg.track_not_found')
        raise PlaylistRequestError.new(items[:message])
      end

      if not referrer_valid?(referer)
        items[:message] = I18n.t('search.request_msg.invalid_referrer', host: default_url_options.to_h[:host])
        raise PlaylistRequestError.new(items[:message])
      end

      if user_ipaddr.ipv4? && tor_exit_node?(userip, server_addr, server_port)
        items[:message] = I18n.t('search.request_msg.ip_of_torel')
        raise PlaylistRequestError.new(items[:message])
      end

      # if not ip_reverse_dns_match?(userip)
      #   items[:message] = I18n.t('search.request_msg.ip_reverse_dns_not_match')
      #   raise PlaylistRequestError.new(items[:message])
      # end

      if is_proxies?(userip)
        items[:message] = I18n.t('search.request_msg.ip_of_proxies')
        raise PlaylistRequestError.new(items[:message])
      end

      track_id = track.id
      title = track.title
      artist = track.artist
      szhash = track.szhash

      # 歌手名稱簡化
      # '/^.+[【（\[\(]*[ ]*(?:feat\.?|from)[ ]*(.+?)[ ]*$/iu  // *** feat. *** or *** from ***
      # /^[ ]*.+?[ ]*[【（\(][ ]*(.+?)[ ]*[\)）】][ ]*$/iu  // *** (***)
      # /^[ ]*(.+?)[ ]*(?:[、﹑·．‧・&＆]|with).+$/iu  // ***、***、***

      # 歌曲名稱簡化
      # /^.*?『(.*?)』.*$/iu  // ***『***』***
      # /^[ ]*(.+?)[ ]*[【（\[\(]*[ ]*(?:feat\.?|from).+$/iu  // *** feat. *** or *** from ***
      # /^[ ]*(?:[【（\[\(].*?[\)\]）】].*?)*[ ]*(.+?)[ ]*(?:[【（\[\(～〜\-].*?[\-～〜\)\]）】].*)*$/iu

      simplify_title_regex = /^(.+?)(?:feat\.?|from|\(|\[|\uFF08|\u3010|\-|~|\uFF5E|\u301C)/i
      simplify_title_match = track.title.match(simplify_title_regex)
      title = simplify_title_match[1].strip if simplify_title_match

      items[:hash] = szhash
      items[:title] = title
      items[:artist] = artist
      items[:nexttime] = track.nexttime.to_i

      CacheLock.synchronize(:request) do
        if Playlist.joins(:track).where('tracks.szhash' => szhash).limit(1).load.first
          items[:message] = I18n.t('search.request_msg.track_already_on_playlist')
          raise PlaylistRequestError.new(items[:message])
        end

        if track.nexttime > Time.now.utc
          items[:message] = I18n.t('search.request_msg.track_in_cooldown_time')
          raise PlaylistRequestError.new(items[:message])
        end

        if not track.requestable?
          items[:message] = I18n.t('search.request_msg.track_not_ready')
          raise PlaylistRequestError.new(items[:message])
        end

        if History.joins(:track).where('histories.created_at > ?', Time.now.utc - 6.hours)
                                .where('tracks.title LIKE ?', "#{title}%").first
          items[:message] = I18n.t('search.request_msg.track_same_name_in_history', hours: 6)
          raise PlaylistRequestError.new(items[:message])
        end

        if track.cooldown_time > 0
          track_ids = Playlist.joins(:track).queue
                                            .where('tracks.cooldown_time > ?', 0)
                                            .order(id: :desc).map(&:track_id)
          if track_ids.present?
            items[:message] = I18n.t('search.request_msg.track_with_cooldown_time_on_playlist')
            raise PlaylistRequestError.new(items[:message])
          end
          if History.joins(:track).where('histories.created_at > ?', Time.now.utc - 8.hours)
                                  .where('tracks.cooldown_time > ?', 0).first
            items[:message] = I18n.t('search.request_msg.track_with_cooldown_time_in_history', hours: 8)
            raise PlaylistRequestError.new(items[:message])
          end
        end

        track_ids = Playlist.queue.order(id: :desc).map(&:track_id)
        if track_ids.present? && Track.where('title LIKE ?', "#{title}%").where(id: track_ids).first
          items[:message] = I18n.t('search.request_msg.track_same_name_on_playlist')
          raise PlaylistRequestError.new(items[:message])
        elsif track_ids.present? && Track.where(artist: artist).where(id: track_ids).first
          items[:message] = I18n.t('search.request_msg.track_same_artist_on_playlist')
          raise PlaylistRequestError.new(items[:message])
        end

        # track_ids = Playlist.queue.order(id: :desc).limit(2).map(&:track_id)
        # if track_ids.present?
        #   if Track.where(artist: artist).where(id: track_ids).first
        #     items[:message] = I18n.t('search.request_msg.artist_in_range_on_playlist')
        #     raise PlaylistRequestError.new(items[:message])
        #   end
        # end

        if Playlist.all.size >= 15
          items[:message] = I18n.t('search.request_msg.max_tracks_on_playlist')
          raise PlaylistRequestError.new(items[:message])
        end

        playlist_queue = Playlist.queue
        playlist_by_userip = Playlist.queue.where(userip: userip)
        if playlist_queue.size != playlist_by_userip.size
          client_ips.each do |ip|
            playlist_by_ip = Playlist.queue.where('userip = ? OR aliasip LIKE ?', ip, "%'#{ip}'%")
            if playlist_by_ip.first
              items[:message] = I18n.t('search.request_msg.ip_already_on_playlist')
              raise PlaylistRequestError.new(items[:message])
            end
          end
        end

        playlist_by_masked_addr = Playlist.queue.where('userip LIKE ?', masked_addr.gsub('.0', '.%'))
        if playlist_by_masked_addr.size >= 3
          items[:message] = I18n.t('search.request_msg.ip_range_on_playlist', count: 3)
          raise PlaylistRequestError.new(items[:message])
        end

        delta_time = 8.days - (Time.now.utc - track.nexttime).abs
        cooldown_time = track.cooldown_time * 1.day + 1.hour if track.cooldown_time > 0
        cooldown_time ||= 8.days if track.duration >= 10.minutes
        cooldown_time ||= delta_time > 25.hours ? delta_time : 25.hours

        nexttime = Time.now.utc + cooldown_time

        items[:status] = 200
        items[:message] = I18n.t('search.request_msg.request_success')
        items[:nexttime] = nexttime.to_i
        session[:forwarded_for] = forwarded_for

        Track.where(szhash: szhash).update_all(nexttime: nexttime)
        track.playlists.create!(
          nickname: nickname,
          useragent: useragent,
          userip: userip,
          aliasip: forwarded_str
        )
        Rails.cache.delete(:playlist)
      end
    rescue PlaylistRequestError => e
      items[:status] = 500
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
    end
  end

  def tor_exit_node?(remote_addr, server_addr, server_port)
    reversed_remote_addr = remote_addr.split('.').reverse.join('.')
    reversed_server_addr = server_addr.split('.').reverse.join('.')
    qh = "#{reversed_remote_addr}.#{server_port}.#{reversed_server_addr}.ip-port.exitlist.torproject.org"
    address = @dns.getaddress(qh)
    address == '127.0.0.2'
  rescue Resolv::ResolvError => e
    false
  rescue Resolv::ResolvTimeout => e
    nil
  end

  def ip_reverse_dns_match?(address)
    hostname = @dns.getname(address)
    hostaddr = @dns.getaddress(hostname)
    hostaddr == address
  rescue Resolv::ResolvError => e
    false
  rescue Resolv::ResolvTimeout => e
    nil
  end

  def is_proxies?(address)
    hostaddr = @dns.getname(address)
    return true if hostaddr.to_s.end_with?('.gae.googleusercontent.com')
    false
  rescue Resolv::ResolvError => e
    false
  rescue Resolv::ResolvTimeout => e
    nil
  end

  def referrer_valid?(referrer)
    uri = URI.parse(referrer.to_s) rescue nil
    return false if uri.nil?
    uri.host == default_url_options.to_h[:host]
  end
end

class PlaylistRequestError < StandardError
  attr_reader :object

  def initialize(object)
    @object = object
  end
end
