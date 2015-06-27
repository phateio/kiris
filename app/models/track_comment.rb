class TrackComment < ActiveRecord::Base
  belongs_to :track, counter_cache: true

  validates :message, presence: true

  def editable?(userip, identity)
    self.userip == userip || self.identity == identity
  end
end
