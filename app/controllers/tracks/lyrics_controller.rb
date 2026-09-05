class Tracks::LyricsController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def show
    set_site_title("#{I18n.t('search.lyrics')}##{track_id}")
    @track = Track.find(track_id)
    @lyric = @track.lyric
  end

  private
    def track_id
      params[:track_id]
    end
end
