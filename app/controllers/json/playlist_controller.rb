require 'cache_lock'

class Json::PlaylistController < ApplicationController
  layout false

  def index
    items = []
    timeout = 60.seconds

    CacheLock.synchronize(:playlist) do
      catch (:done) do
        items = Rails.cache.read(:playlist) || []
        throw :done if items.present?

        playlist_colle = Playlist.includes(:track, {track: :images}).order(playedtime: :desc, id: :asc).load
        playlist_colle.each_with_index do |playlist, index|
          track = playlist.track

          if index < 3
            images = track.images.order(id: :asc).select { |image| (/\ARANK_(?:2|3|4|5)\z/ =~ image.status) != nil }
            image = images.present? ? images.at(playlist.id % images.size) : nil

            if image
              image_info = {url: image.url,
                            source: image.source,
                            nickname: image.nickname,
                            illustrator: image.illustrator}
            else
              image_info = {url: nil,
                            source: nil,
                            nickname: nil,
                            illustrator: nil}
            end

            lyric = track.lyric ? track.lyric.text.gsub(/\[[\w\.: ]+\][\s\r\n]*/, '') : ''
          else
            images = []
            image_info = {}
            lyric = nil
          end

          # images = track.images.select { |image| image.status != 'RANK_BAKA' }
          # image_index = images.present? ? playlist.id % images.size : nil
          # image_detail_colle = images.collect.with_index do |image, i|
          #   {
          #     url: image.url,
          #     source: image.source,
          #     illustrator: image.illustrator,
          #     selected: i == image_index
          #   }
          # end

          items << {
            id: playlist.id,
            track_id: track.id,
            playedtime: playlist.playedtime,
            artist: track.artist,
            title: track.title,
            tags: track.tags,
            duration: track.duration,
            hash: track.szhash,
            image: image_info,
            images: [],
            lyrics: lyric,
            nickname: 'Anonymous',
            timeleft: track.duration
          }

          if playlist.playedtime > Time.at(0).utc
            timeleft = playlist.playedtime + track.duration - Time.now.utc
            timeout = timeleft >= 1 ? timeleft.to_i : 1.second
          end
        end

        Rails.cache.write(:playlist, items, expires_in: timeout)
      end
    end

    # render json: JSON.parse(http_get_response_body('http://phate.io/playlist.json')) and return

    items.each do |item|
      playedtime = item[:playedtime]
      duration = item[:duration]
      if playedtime > Time.at(0).utc
        timeleft = playedtime + duration - Time.now.utc
        timeleft = 0 if timeleft < 0
        item[:timeleft] = timeleft.to_i
      end
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
    end
  end
end
