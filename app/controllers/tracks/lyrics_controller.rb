class Tracks::LyricsController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def show
    set_site_title("#{I18n.t('search.lyrics')}##{track_id}")
    @track = Track.find(track_id)
    @lyric = @track.lyric
  end

  def edit
    set_site_title("#{I18n.t('search.lyrics')}##{track_id}")
    @track = Track.find(track_id)
    @lyric = @track.lyric || @track.build_lyric
  end

  def create
    set_site_title("#{I18n.t('search.lyrics')}##{track_id}")
    userip = @client[:ip]
    @track = Track.find(track_id)
    @lyric = @track.build_lyric(lyric_params)
    @lyric.attributes = {userip: userip}
    render action: 'show' and return unless @lyric.save
    x_redirect_to track_lyrics_path(@track)
  end

  def update
    set_site_title("#{I18n.t('search.lyrics')}##{track_id}")
    userip = @client[:ip]
    @track = Track.find(track_id)
    @lyric = @track.lyric
    render action: 'show' and return unless @lyric.update(lyric_params.merge(userip: userip))
    x_redirect_to track_lyrics_path(@track)
  end

  private
  def track_id
    params[:track_id]
  end

  def lyric_params
    params.require(:lyric).permit(:text,)
  end
end
