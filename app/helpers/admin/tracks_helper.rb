module Admin::TracksHelper
  def render_admin_track_form(track, form_for_option_url)
    render partial: 'track_form', :locals => {track: track, form_for_option_url: form_for_option_url}
  end

  def render_admin_track_list(tracks)
    render partial: 'track_list', :locals => {tracks: tracks}
  end

  def render_admin_track_list_item(track)
    render partial: 'track_list_item', :locals => {track: track}
  end

  def render_admin_track_list_item_header
    render partial: 'track_list_item_header'
  end

  def render_admin_track_comments_link(track)
    render partial: 'track_list_column_track_comments_link', :locals => {track: track}
  end

  def render_admin_track_edit_link(track)
    return unless @access > 0
    link_to t('form.edit'), edit_admin_track_path(track), class: 'track-edit-link', remote: true
  end

  def render_admin_track_review_link(track)
    return unless @access > 0
    link_to 'Review', review_admin_track_path(track), class: 'track-review-link', remote: true
  end

  def render_admin_track_delete_link(track)
    return unless @access > 0
    confirm_message = 'Are you sure you want to delete this track?'
    link_to t('form.delete'), admin_track_path(track), method: :delete, class: 'track-delete-link', remote: true, data: {confirm: confirm_message}
  end

  def render_admin_track_niconico_link(track)
    return '-' if track.niconico.nil?
    link_to track.niconico, track.niconico_url, target: '_blank'
  end
end
