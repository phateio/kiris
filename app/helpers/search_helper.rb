module SearchHelper
  def render_request_rules
    render partial: 'request_rules'
  end

  def render_history_list(histories)
    render partial: 'history_list', :locals => {histories: histories}
  end

  def render_history_columns(history)
    track = history.track
    render partial: 'history_list_columns', :locals => {history: history, track: track}
  end

  def render_history_columns_header
    render partial: 'history_list_columns_header'
  end

  def render_latest_list(tracks)
    render partial: 'latest_list', :locals => {tracks: tracks}
  end

  def render_latest_columns(track)
    render partial: 'latest_list_columns', :locals => {track: track}
  end

  def render_latest_columns_header
    render partial: 'latest_list_columns_header'
  end

  def render_search_list(tracks)
    render partial: 'search_list', :locals => {tracks: tracks}
  end

  def render_search_columns(track, index)
    numero = index + 1 + (@page - 1) * 25
    render partial: 'search_list_columns', :locals => {track: track, numero: numero}
  end

  def render_search_columns_header
    render partial: 'search_list_columns_header'
  end

  def render_search_list_column_class(track)
    track.requestable? ? nil : 'disabled'
  end

  def render_search_list_column_request(track)
    render partial: 'search_list_column_request', :locals => {track: track}
  end

  def render_search_list_column_track_link(track)
    link_to track.title, track_path(track), remote: true
  end

  def render_search_list_column_track_images_link(track)
    render partial: 'search_list_column_track_images_link', :locals => {track: track}
  end

  def render_search_list_column_track_lyrics_link(track)
    render partial: 'search_list_column_track_lyrics_link', :locals => {track: track}
  end

  def render_search_list_column_track_comments_link(track)
    render partial: 'search_list_column_track_comments_link', :locals => {track: track}
  end
end
