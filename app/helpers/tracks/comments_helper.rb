module Tracks::CommentsHelper
  def render_track_nickname_with_tripcode(track_comment)
    suffix = track_comment.userip.empty? ? 'Member' : tripcode(track_comment.userip)
    "#{track_comment.nickname}†#{suffix}"
  end

  def render_track_comment_form(track_comment)
    render partial: 'track_comment_form', :locals => {track_comment: track_comment}
  end

  def render_track_comment_list(track_comments)
    render partial: 'track_comment_list', :locals => {track_comments: track_comments}
  end

  def render_track_comment_item(track_comment)
    render partial: 'track_comment_item', :locals => {track_comment: track_comment}
  end

  def render_track_comment_item_header(track_comment)
    render partial: 'track_comment_item_header', :locals => {track_comment: track_comment}
  end

  def render_track_comment_toolbar_field
    content_tag :div, class: 'toolbar-field' do
      link_to t('form.refresh'), {}, class: 'button btn-refresh', remote: true
    end
  end
end
