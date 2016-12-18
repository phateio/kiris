require 'streammeta'

class Track < ActiveRecord::Base
  include SharedMethods
  before_validation :normalize_values
  before_validation :normalize_tags

  has_many :playlists, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :track_comments, dependent: :destroy
  has_one  :lyric, dependent: :destroy

  validates :title, presence: true
  validates :szhash, presence: true, if: Proc.new { |track| track.requestable? }
  validates :niconico, format: {with: /\A[A-Za-z0-9]+\z/}, allow_blank: true

  scope :randomize, -> { order('RANDOM()') }

  scope :requestable, -> { where(status: 'OK') }
  scope :not_requestable, -> { where.not(status: 'OK') }
  scope :utaitedb, -> { where(uploader: 'utaitedb.net') }
  scope :niconico_tracks, -> { where.not(niconico: '') }
  scope :niconico_idle_tracks, -> { niconico_tracks.not_requestable }
  scope :niconico_queued_tracks, -> { niconico_tracks.where(status: 'QUEUED') }

  scope :arel_niconico_tracks, -> { arel_table[:niconico].not_eq('') }
  scope :arel_recent_tracks, -> { arel_table[:created_at].gt(Time.now.utc - 30.days) }
  scope :arel_idle_tracks, -> { arel_table[:status].not_eq('OK') }

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
