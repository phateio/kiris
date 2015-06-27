class NoticesController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.news'))
    @notices = Notice.order(dateline: :desc, id: :desc)
  end
end
