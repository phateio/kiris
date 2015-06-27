class UploadController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.upload'))
    @statistics = Track.group(:uploader).count.reject { |key| key.empty? }.sort_by { |key, value| value }.reverse
  end
end
