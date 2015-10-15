require 'json'

class Tracks::ImagesController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def index
    set_site_title("#{I18n.t('navbar.images')}##{track_id}")
    @image = Image.new
    @image.track = Track.find(track_id)
    @images = Image.includes(:track).where(track_id: track_id).order(id: :desc).page(page).per(20).load
  end

  def create
    set_site_title("#{I18n.t('navbar.images')}##{track_id}")
    userip = @client[:ip]
    @track = Track.find(track_id)
    @image = @track.images.build(image_params)
    @image.attributes = {userip: userip}
    @images = Image.includes(:track).where(track_id: track_id).order(id: :desc).page(page).per(20).load
    case is_valid_content_type?(@image.url)
    when nil
      @image.errors.add(:url, 'does not exist or request timed-out')
      render action: 'index' and return
    when false
      @image.errors.add(:url, :invalid_content_type)
      render action: 'index' and return
    end
    pixiv_regexp = /\A(?:http:\/\/www\.pixiv\.net\/member_illust\.php\?mode=medium&illust_id=([0-9]+))\z/
    case @image.source
    when pixiv_regexp
      pixiv_match = pixiv_regexp.match(@image.source)
      pixiv_illust_id = pixiv_match[1]
      pixiv_illust_info = get_pixiv_illust_info(pixiv_illust_id)
      if not pixiv_illust_info
        @image.errors.add(:source, 'does not exist or request timed-out')
        render action: 'index' and return
      end
      @image.illustrator = pixiv_illust_info[:nickname]
    end
    render action: 'index' and return if not @image.save
    x_redirect_to track_images_path(@track)
  end

  private
    def track_id
      params[:track_id]
    end

    def image_params
      params.require(:image).permit(:url, :source, :nickname)
    end

    def is_valid_content_type?(url)
      res = http_head_response(url) rescue nil
      return nil if res.nil?
      ['image/jpeg', 'image/png'].include?(res['Content-Type'])
    end

    def get_pixiv_illust_info(illust_id)
      headers = {
        'Authorization' => $PIXIV_AUTHORIZATION
      }
      res_body = http_get_response_body("https://public-api.secure.pixiv.net/v1/works/#{illust_id}.json?image_sizes=large", headers) rescue nil
      return nil if res_body.nil?
      illust_hash = JSON.parse(res_body)
      return false if illust_hash['status'] != 'success'
      illust_hash_response = illust_hash['response'].first
      {
        illust_id: illust_hash_response['id'],
        image_url: illust_hash_response['image_urls']['large'],
        nickname: illust_hash_response['user']['name'],
        tags: illust_hash_response['tags'],
        type: illust_hash_response['type']
      }
    end
end
