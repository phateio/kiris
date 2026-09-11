class Admin::TracksController < ApplicationController
  before_action :load_internal_style_sheet!
  before_action :authenticate

  def index
    set_site_title(I18n.t('admin.track.title'))
    @tracks = Track.not_requestable.order(id: :asc).page(page)
  end

  def new
    set_site_title(I18n.t('admin.track.title'))
    @track = Track.new
  end

  def create
    set_site_title(I18n.t('admin.track.title'))
    @track = Track.new(track_params)
    render 'new' and return if not @track.save
    x_redirect_to redirect_to_params || admin_tracks_path
  end

  def edit
    @track = Track.find(track_id)
    set_site_title(I18n.t('admin.track.title_with_index', id: @track.id))
    @redirect_to = request_referer
  end

  def update
    @track = Track.find(track_id)
    set_site_title(I18n.t('admin.track.title_with_index', id: @track.id))
    render 'edit' and return if not @track.update(track_params)
    x_redirect_to redirect_to_params || admin_tracks_path
  end

  def review
    @track = Track.find(track_id)
    set_site_title(I18n.t('admin.track.review_title_with_index', id: @track.id))
    @track.requestable!
    @redirect_to = request_referer
    render 'review'
  end

  def confirm
    @track = Track.find(track_id)
    set_site_title(I18n.t('admin.track.review_title_with_index', id: @track.id))
    render 'review' and return if not @track.update(track_params)
    x_redirect_to redirect_to_params || admin_tracks_path
  end

  def destroy
    @track = Track.find(track_id)
    @track.destroy
    x_redirect_to redirect_to_params || admin_tracks_path
  end

  private
  def track_id
    params[:id]
  end

  def track_params
    params.require(:track).permit!
  end
end
