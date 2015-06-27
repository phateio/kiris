class TracksController < ApplicationController
  before_action :load_internal_style_sheet!

  def show
    @track = Track.find(track_id)
    set_site_title(I18n.t('tracks.title_with_index', id: @track.id))
  end

  private
  def track_id
    params[:id]
  end
end
