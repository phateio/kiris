class CategoryController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.category'))
    @items = []
    @items = Rails.cache.fetch(:category, expires_in: 1.day) do
      categories = Category.order(gid: :asc, tid: :asc)
      categories.each do |category|
        @items << {
          gid: category.gid.to_i,
          tid: category.tid.to_i,
          title: category.title,
          keyword: category.keyword,
          comment: category.comment
        }
      end
      @items
    end
  end
end
