module Upload::NiconicoHelper
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

  def render_track_niconico_link(track)
    link_to track.niconico, track.niconico_url, target: '_blank'
  end
end
