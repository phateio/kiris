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
end
