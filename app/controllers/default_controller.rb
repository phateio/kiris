class DefaultController < ApplicationController
  before_action :load_internal_style_sheet!, except: [:index]

  def index
    @page_title = @site_name
    @page_description = I18n.t('metainfo.description')
    @page_keywords = I18n.t('metainfo.sitetags')
  end

  def chat
    set_site_title(I18n.t('navbar.chat'))
  end

  def faq
    set_site_title(I18n.t('navbar.faq'))
  end

  def speed
    set_site_title(I18n.t('navbar.speed'))
  end

  def support
    set_site_title(I18n.t('navbar.support'))
  end

  def preferences
    set_site_title(I18n.t('navbar.preferences'))
  end
end
