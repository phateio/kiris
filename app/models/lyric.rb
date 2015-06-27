class Lyric < ActiveRecord::Base
  belongs_to :track

  validates :text, presence: true

  def editable?(userip, identity)
    self.userip == userip || self.identity == identity
  end
end
