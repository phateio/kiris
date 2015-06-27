class ImagesController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.images'))
    @images = Image.includes(:track).order(id: :desc).page(page).per(20).load
  end

  def show
    set_site_title("#{I18n.t('navbar.images')}##{track_id}")
    @image = Image.new
    @image.track = Track.find(track_id)
    @images = Image.includes(:track).where(track_id: track_id).order(id: :desc).page(page).per(20).load
  end

  private
  def track_id
    params[:track_id]
  end

  def image_params
    params.require(:image).permit(:url, :source, :nickname)
  end
end
