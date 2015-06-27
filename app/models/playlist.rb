class Playlist < ActiveRecord::Base
  belongs_to :track

  scope :queue, -> { where(playedtime: Time.at(0).utc) }
end
