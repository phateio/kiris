class Integer
  def abbrtime
    duration = self
    time_min = (duration / 60).floor
    time_sec = (duration % 60).floor
    time_min.to_s + ':' + (time_sec < 10 ? '0' : '') + time_sec.to_s
  end
end
