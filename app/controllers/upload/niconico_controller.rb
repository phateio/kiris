class Upload::NiconicoController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('upload.niconico.title'))
    track_arel_recent_or_idle_niconico_tracks = Track.arel_recent_tracks
                                                .or(Track.arel_idle_tracks)
                                                .and(Track.arel_niconico_tracks)
    @tracks = Track.where(track_arel_recent_or_idle_niconico_tracks).order(id: :desc).page(page)
  end

  def new
    set_site_title(I18n.t('upload.niconico.title'))
    @track = Track.new
  end

  def fetch
    set_site_title(I18n.t('upload.niconico.title'))
    @track = Track.new(track_params)
    if @track.niconico.empty?
      flash.now[:error] = I18n.t('upload.niconico.blank_niconico_id')
      render 'new' and return
    end
    raw_video_id = @track.niconico.to_s.strip
    if raw_video_id =~ /\A[A-Za-z0-9]+\z/i
      niconico_location = get_niconico_location(raw_video_id)
      if niconico_location
        matches = /\/watch\/([A-Za-z0-9]+)/i.match(niconico_location)
        video_id = matches.to_a.last
      else
        video_id = raw_video_id
      end
    else
      matches = /\/watch\/([A-Za-z0-9]+)/i.match(raw_video_id)
      video_id = matches.to_a.last
    end
    if video_id.nil?
      flash.now[:error] = I18n.t('upload.niconico.invalid_niconico_id')
      render 'new' and return
    elsif Track.where(niconico: video_id).present? || Track.where(niconico: video_id).present?
      flash.now[:error] = I18n.t('upload.niconico.duplicate_niconico_id')
      render 'new' and return
    end
    set_site_title("#{I18n.t('upload.niconico.title')}#niconico-#{video_id}")
    @track.niconico = video_id
    niconico_video_info = get_niconico_thumb_info(video_id)
    if niconico_video_info == false
      flash.now[:error] = I18n.t('upload.niconico.niconico_id_not_found')
      render 'new' and return
    end
    unless ['mp4', 'swf', 'flv'].include?(niconico_video_info[:movie_type])
      flash.now[:error] = I18n.t('upload.niconico.movie_type_not_supported', movie_type: niconico_video_info[:movie_type])
      render 'new' and return
    end
    unless niconico_video_info[:view_counter] > 10000
      count = ActionController::Base.helpers.number_with_delimiter(10000)
      flash.now[:error] = I18n.t('upload.niconico.view_counter_not_enough', count: count)
      render 'new' and return
    end
    union_tags = niconico_video_info[:tags] & niconico_acceptable_tags
    unless union_tags.present?
      flash.now[:error] = I18n.t('upload.niconico.acceptable_tags_not_found')
      render 'new' and return
    end
    @track.attributes = {
      title: niconico_video_info[:title],
      tags: 'niconico,' + union_tags.join(',')
    }
  end

  def create
    set_site_title(I18n.t('upload.niconico.title'))
    @track = Track.new(track_params)
    @track.attributes = {
      album: 'ニコニコ',
      userip: @client[:ip],
      status: 'QUEUED',
      identity: @identity
    }
    track_tags = @track.tags.split(',')
    union_tags = track_tags & niconico_acceptable_tags
    unless track_tags.include?('niconico') && union_tags.present?
      flash.now[:error] = I18n.t('upload.niconico.reserved_tags_not_found')
      render 'fetch' and return
    end
    render 'fetch' and return if not @track.save
    x_redirect_to upload_niconico_index_path
  end

  def edit
    set_site_title(I18n.t('upload.niconico.title'))
    @track = Track.find(track_id)
  end

  def update
    set_site_title(I18n.t('upload.niconico.title'))
    @track = Track.find(track_id)
    redirect_to_index_if_not_permitted(@track); return if performed?
    @track.attributes = track_params
    if @track.status == 'PUBLIC'
      @track.attributes = {
        userip: @client[:ip],
        status: 'READY',
        identity: @identity
      }
    end
    track_tags = @track.tags.split(',')
    union_tags = track_tags & niconico_acceptable_tags
    unless track_tags.include?('niconico') && union_tags.present?
      flash.now[:error] = I18n.t('upload.niconico.reserved_tags_not_found')
      render 'edit' and return
    end
    render 'edit' and return if not @track.save
    x_redirect_to upload_niconico_index_path
  end

  def destroy
    @track = Track.find(track_id)
    redirect_to_index_if_not_permitted(@track); return if performed?
    @track.destroy
    x_redirect_to upload_niconico_index_path
  end

  private
  def track_id
    params[:track_id]
  end

  def niconico_acceptable_tags
    ['VOCALOID', 'UTAU', '東方Project', '歌ってみた', '音楽']
  end

  def niconico_touhou_tags
    ['東方アレンジ', '東方ヴォーカル']
  end

  def track_params
    params.require(:track).permit(track_attribute_names)
  end

  def track_attribute_names
    [
      :title,
      :tags,
      :artist,
      :niconico,
      :uploader
    ]
  end

  def redirect_to_index_if_not_permitted(track)
    if not track.editable?(@client[:ip], @identity)
      flash[:error] = 'Access Denied.'
      x_redirect_to upload_niconico_index_path and return
    end
  end

  def get_niconico_location(video_id)
    res = http_head_response("https://www.nicovideo.jp/watch/#{video_id}") rescue nil
    return nil if res.nil?
    res['Location']
  end

  def get_niconico_thumb_info(video_id)
    res_body = http_get_response_body("https://ext.nicovideo.jp/api/getthumbinfo/#{video_id}") rescue nil
    return false if res_body.nil?
    thumb_info_doc = Nokogiri::XML(res_body)
    thumb_element = thumb_info_doc.xpath('/nicovideo_thumb_response/thumb')
    document_element = thumb_info_doc.xpath('/nicovideo_thumb_response/thumb')
    document_hash = Hash.from_xml(thumb_element.to_s)
    return false if document_hash.nil?
    thumb_hash = document_hash['thumb']
    thumb_hash.slice!('video_id', 'title', 'length', 'movie_type', 'view_counter', 'tags')
    thumb_hash.symbolize_keys!
    thumb_hash[:tags] = Array(thumb_hash[:tags].to_h['tag'])
    thumb_hash[:tags] = thumb_hash[:tags].map { |tag| niconico_touhou_tags.include?(tag) ? '東方Project' : tag }.uniq
    thumb_hash[:view_counter] = thumb_hash[:view_counter].to_i
    thumb_hash
  end
end
