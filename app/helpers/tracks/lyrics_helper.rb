module Tracks::LyricsHelper
  def render_lyric_form(lyric)
    render partial: 'lyric_form', :locals => {lyric: lyric}
  end
end
