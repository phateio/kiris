require 'yp_directory'

class Bridge::PlaylistController < ApplicationController
  skip_before_filter :verify_authenticity_token

  layout false

  def index
    items = []
    playlist_colle = Playlist.includes(:track).order(playedtime: :desc, id: :asc).limit(4).load
    playlist_colle.each do |playlist|
      track = playlist.track
      if playlist.playedtime > Time.at(0).utc
        next unless playlist.playedtime + track.duration + 45.seconds < Time.now
        track = Track.find($OFFLINE_TRACK_ID || 1)
      end
      items << track_item(track)
    end
    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end

  def update
    secret_key = request.POST[:secret_key]
    szhash = request.POST[:szhash] || request.POST[:hash]
    if secret_key != $BRIDGE_SECRET_KEY
      render nothing: true, status: :forbidden and return
    end
    track = Track.where(szhash: szhash).first
    track_id = request.POST[:id] || track.id
    Playlist.where.not(playedtime: Time.at(0).utc).destroy_all
    playlist = Playlist.find_or_create_by!(track_id: track_id)
    playlist.with_lock do
      playlist.update(playedtime: Time.now.utc)
      playlist.save!
    end
    szhash = playlist.track.szhash
    new_count = playlist.track.count + 1
    Track.where(szhash: szhash).update_all(count: new_count, updated_at: Time.now.utc)
    ActiveRecord::Base.transaction do
      History.where('playedtime < ?', Time.now.utc - 30.days).destroy_all
    end
    History.create!(playedtime: Time.now.utc, track_id: track_id)
    track = playlist.track

    Thread.new do
      http_get_post_form_body('http://danmaku.phate.io/metadata',
                              'title' => track.title,
                              'artist' => track.artist,
                              'tags' => track.tags,
                              'secret_key' => $DANMAKU_SECRET_KEY) rescue nil
    end

    Thread.new do
      cached_status = Rails.cache.read(:status)
      Thread.exit if cached_status.nil?
      listeners = cached_status[:listeners]
      ypd = YPDirectory.new('http://dir.xiph.org/cgi-bin/yp-cgi')
      ypd.add(
        sn: 'Phate Radio',
        listenurl: listen_url(protocol: 'http', format: 'ogg'),
        desc: 'Phate Radio is an experimental internet radio about anime, games and pop music.',
        genre: 'Jpop Anime',
        b: 128,
        type: 'application/ogg',
        url: 'https://phate.io/'
      ) unless ypd.connected?
      ypd.touch(st: track.long_title, listeners: listeners)
    end

    track.update!(status: 'DELETED') unless track.uploader.eql?('utaitedb.net')

    render nothing: true
    Rails.cache.delete(:playlist)
  end

  def randlist
    items = []
    played_tracks = Track.joins(:histories).where(History.arel_table[:playedtime].gt(7.days.ago))
    available_tracks = Track.where.not(id: played_tracks).requestable.utaitedb.implicit
    track_size = available_tracks.size
    offset = track_size >= 2000 ? rand(2000) : rand(track_size)
    tracks = available_tracks.order(count: :desc).offset(offset).limit(1)

    tracks.each do |track|
      items << track_item(track)
      track.touch
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end

  private
    def track_item(track)
      {
        id: track.id,
        hash: track.szhash,
        szhash: track.szhash,
        title: track.title,
        artist: (track.artist.blank? ? 'Null' : track.artist)
      }
    end
end
