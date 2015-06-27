class Tracks::CommentsController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('tracks.comments.title_with_track_index', id: track_id))
    @track = Track.find(track_id)
    @track_comment = @track.track_comments.new
    @track_comments = @track.track_comments.order(id: :asc).select(&:persisted?)
  end

  def create
    set_site_title(I18n.t('tracks.comments.title_with_track_index', id: track_id))
    @track = Track.find(track_id)
    @track_comment = @track.track_comments.build(track_comment_params)
    @track_comment.attributes = {useragent: @client[:useragent],
                                 userip: @client[:ip],
                                 identity: @identity}
    @track_comments = @track.track_comments.order(id: :asc).select(&:persisted?)
    render 'index' and return if not @track_comment.save
    x_redirect_to track_comments_path(@track)
  end

  def update
    set_site_title(I18n.t('tracks.comments.title_with_track_index', id: track_id))
    @track = Track.find(track_id)
    @track_comment = @track.find(track_comment_id)
    @track_comments = @track.track_comments.order(id: :asc).select(&:persisted?)
    redirect_to_index_if_not_permitted(@track_comment); return if performed?
    render 'index' and return if not @track_comment.update(track_comment_params)
    x_redirect_to track_comments_path(@track)
  end

  def destroy
    @track = Track.find(track_id)
    @track_comment = @track.find(track_comment_id)
    redirect_to_index_if_not_permitted(@track_comment); return if performed?
    @track_comment.destroy
    x_redirect_to track_comments_path(@track)
  end

  private
  def track_id
    params[:track_id]
  end

  def track_comment_id
    params[:id]
  end

  def track_comment_params
    params.require(:track_comment).permit(track_comment_attribute_names)
  end

  def track_comment_attribute_names
    [
      :message,
      :nickname
    ]
  end

  def redirect_to_index_if_not_permitted(track_comment)
    if not track_comment.editable?(@client[:ip], @identity)
      flash[:error] = 'Access Denied.'
      x_redirect_to tracks_path and return
    end
  end
end
