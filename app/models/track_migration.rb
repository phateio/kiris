require 'streammeta'

class TrackMigration < ActiveRecord::Base
  include SharedMethods
  before_validation :normalize_values
  before_validation :normalize_tags

  has_many :track_migration_comments, dependent: :destroy

  validates :title, presence: true
  validates :niconico, format: {with: /\A[A-Za-z0-9]+\z/}, allow_blank: true

  scope :niconico_tracks, -> { where.not(niconico: '') }
  scope :niconico_idle_tracks, -> { niconico_tracks.not_requestable }
  scope :niconico_queued_tracks, -> { niconico_tracks.where(status: 'QUEUED') }

  def duration_abbrtime
    self.duration.to_i.abbrtime
  end

  def long_title
    title = self.title
    artist = self.artist
    artist ? "#{artist} - #{title}" : title
  end

  def szhash_url
    "#{$STATIC_SERVER_URL}/#{self.szhash[0..1]}/#{self.szhash[2..-1]}.mp3"
  end

  def niconico_url
    "http://www.nicovideo.jp/watch/#{self.niconico}"
  end

  def requestable!
    self.status = 'OK'
  end

  def requestable?
    self.status == 'OK'
  end

  def editable?(userip, identity)
    self.status == 'PUBLIC' ||
    self.status != 'OK' && (self.userip == userip || self.identity == identity)
  end

  private
  def normalize_tags
    self.tags = self.tags.split(',').map(&:strip).reject(&:empty?).join(',')
  end
end
