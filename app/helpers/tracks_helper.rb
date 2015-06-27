module TracksHelper
  def render_track_niconico_link(track)
    return nil if track.niconico.empty?
    link_to track.niconico, track.niconico_url, target: '_blank'
  end
end
