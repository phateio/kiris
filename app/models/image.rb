class Image < ActiveRecord::Base
  include SharedMethods
  before_validation :normalize_values
  before_validation :normalize_image_url

  belongs_to :track, counter_cache: true
  has_many :image_comments, dependent: :destroy

  valid_sources = [
    'http:\/\/www\.pixiv\.net\/member_illust\.php\?mode=medium&illust_id=[0-9]+',
    'http:\/\/piapro\.jp\/t\/[A-Za-z0-9_\-]+',
    'http:\/\/seiga\.nicovideo\.jp\/seiga\/[A-Za-z0-9]+'
  ]
  valid_url_regexp = /\A\/\/i\.imgur\.com\/[A-Za-z0-9]+\.(?:jpg|png)\z/
  valid_source_regexp = /\A(?:#{valid_sources.join('|')})\z/

  validates :url, presence: true
  validates :url, format: {with: valid_url_regexp, message: :invalid_format}, unless: :verified?
  validates :source, format: {with: valid_source_regexp, message: :invalid_format}, allow_blank: true

  def cdn_url
    self[:url].sub('//i.imgur.com/', '/imgur/')
  end

  def thumbnail
    if %r{//i\.imgur\.com/} === url
      cdn_url.gsub(/(\.[A-Za-z]+)$/, 's\1')
    else
      url.gsub(/(\.[A-Za-z]+)$/, '_square1200.jpg')
    end
  end

  def source_abbreviation
      hash_code = self.source.scan(/[A-Za-z0-9_\-]+$/).first
      case self.source
      when /\Ahttp:\/\/www\.pixiv\.net\/member_illust\.php\?mode=medium&illust_id=[0-9]+\z/i
        return "pixiv##{hash_code}"
      when /\Ahttp:\/\/piapro\.jp\/t\/[A-Za-z0-9_\-]+\z/i
        return "piapro##{hash_code}"
      when /\Ahttp:\/\/seiga\.nicovideo\.jp\/seiga\/[A-Za-z0-9]+\z/i
        return "nicoseiga##{hash_code}"
      else
        return nil
      end
  end

  def status_msg
    self.status.downcase
  end

  def image_editable?(userip, identity)
    self.userip == userip || self.identity == identity
  end

  def normalize_image_url
    self.url.gsub!(/^https?:/, '')
  end
end
