class Admin::ImagesController < ApplicationController
  before_action :load_internal_style_sheet!
  before_action :authenticate
  helper_method :status_msgs

  def index
    set_site_title(I18n.t('admin.images.background_management'))
    @images = Image.joins(:track).includes(:track).where('tracks.status = ?', 'OK').where(status: '').order(id: :asc).page(page).per(20).load
  end

  def show
    set_site_title(I18n.t('admin.images.background_management'))
    id = params[:id]
    @images = Image.where(id: id)
  end

  def import
    attachment = params[:attachment]
    items = JSON.parse(attachment.read)
    destroy_all = request.POST[:destroy_all]

    ActiveRecord::Base.transaction do
      Image.destroy_all if destroy_all

      items.each do |item|
        dateline = item['dateline']
        track_id = item['track_id']
        url = item['url']
        source = item['source']
        nickname = item['nickname']
        userip = item['userip']
        status = item['status']
        identity = item['identity']
        verified = item['verified']
        rate = item['rate']

        image = Image.create!(dateline: dateline,
                              track_id: track_id,
                              url: url,
                              source: source,
                              nickname: nickname,
                              userip: userip,
                              status: status,
                              identity: identity,
                              verified: verified,
                              rate: rate)
      end
    end

    x_redirect_to action: 'index'
  end

  def export
    items = []

    images = Image.order(id: :asc)
    images.each do |image|
      items << {dateline: image.dateline,
                track_id: image.track_id,
                url: image.url,
                source: image.source,
                nickname: image.nickname,
                userip: image.userip,
                status: image.status,
                identity: image.identity,
                verified: image.verified,
                rate: image.rate}
    end

    send_data JSON.pretty_generate(items), filename: 'images.json'
  end

  def image_
    items = {}

    id = request.POST[:image_id]
    status = request.POST[:status]

    image = Image.where(id: id).first

    begin
      raise I18n.t('images.image_not_found') if image.nil?
      raise I18n.t('images.invalid_status') if not status_msgs.include?(status)

      image.update_attributes(status: status)
      items[:status] = 200
    rescue => e
      items[:status] = 500
      render json: items
      return
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
      format.any { head :not_found }
    end
  end

  private
  def status_msgs
    [
      'RANK_5',
      'RANK_4',
      'RANK_3',
      'RANK_2',
      'RANK_1',
      'RANK_0',
      '',
      'RANK_BAKA',
      'REJECTED_LOW_RESOLUTION',
      'REJECTED_POOR_QUALITY',
      'REJECTED_JPEG_ARTIFACTS',
      'REJECTED_SUBPAR_ARTWORK',
      'REJECTED_RESIZED',
      'REJECTED_DUPLICATE',
      'REJECTED_REPLACED',
      'REJECTED_WRONG_PLACE',
      'REJECTED_SCREENSHOT',
      'REJECTED_WATERMARK',
      'REJECTED_POST_PROCESSING',
      'REJECTED_USER_CREATED_CONTENT',
      'REJECTED_SOURCE_INCONSISTENT',
      'REJECTED_OTHER'
    ]
  end
end
