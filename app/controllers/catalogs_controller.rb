class CatalogsController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.catalog'))
    # @catalog = Catalog.order(id: :desc).limit(1).first
    @track_groups = Track.utaitedb
                         .where.not(Track.arel_table[:artist].matches('%、%'))
                         .group(:artist).order('count_all DESC').count.to_a
  end
end
