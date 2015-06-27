module Upload::NiconicoHelper
  def render_niconico_track_rules
    render partial: 'niconico_track_rules'
  end

  def render_niconico_track_tag_format
    render partial: 'niconico_track_tag_format'
  end

  def render_niconico_track_form(track, form_for_option_url)
    render partial: 'niconico_track_form', :locals => {track: track, form_for_option_url: form_for_option_url}
  end

  def render_niconico_track_form_fetch(track, form_for_option_url)
    render partial: 'niconico_track_form_fetch', :locals => {track: track, form_for_option_url: form_for_option_url}
  end

  def render_niconico_track_form_uploader(f)
    f.text_field :uploader, (f.object.new_record? ? {placeholder: t('preferences.nickname_placeholder'), data: {option: 'nickname'}} : {})
  end

  def render_niconico_track_list(tracks)
    render partial: 'niconico_track_list', :locals => {tracks: tracks}
  end

  def render_niconico_track_columns(track)
    render partial: 'niconico_track_list_columns', :locals => {track: track}
  end

  def render_niconico_track_columns_header
    render partial: 'niconico_track_list_columns_header'
  end

  def render_niconico_track_link(track)
    link_to track.title, track_path(track), remote: true
  end

  def render_niconico_track_images_link(track)
    render partial: 'niconico_track_list_column_track_images_link', :locals => {track: track}
  end

  def render_niconico_track_lyrics_link(track)
    render partial: 'niconico_track_list_column_track_lyrics_link', :locals => {track: track}
  end

  def render_niconico_track_comments_link(track)
    render partial: 'niconico_track_list_column_track_comments_link', :locals => {track: track}
  end

  def render_niconico_track_edit_link(track)
    return '-' unless track.editable?(@client[:ip], @identity)
    link_to t('form.edit'), edit_upload_niconico_path(track), remote: true
  end

  def render_niconico_track_delete_link(track)
    return '-' unless track.editable?(@client[:ip], @identity)
    confirm_message = 'Are you sure you want to delete this track?'
    link_to t('form.delete'), upload_niconico_path(track), method: :delete, remote: true, data: {confirm: confirm_message}
  end

  def render_track_niconico_link(track)
    link_to track.niconico, track.niconico_url, target: '_blank'
  end
end
