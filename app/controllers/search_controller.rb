require 'metacharacters'

class SearchController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.search'))
    if params[:q]
      case params[:q]
      when 'random'
        random_search
      else
        search
      end
    end
  end

  def search
    @keyword = params[:q].strip rescue ''
    set_site_title("#{I18n.t('search.search')}『#{@keyword}』")
    @q = Track.search(search_params)
    if params[:sort] == 'random'
      @tracks = @q.result.randomize.page(page)
    else
      @q.sorts = ['asin asc', 'number asc', 'niconico asc', 'id asc']
      @tracks = @q.result(distinct: true).page(page)
    end
    render action: 'search'
  end

  def random_search
    @keyword = params[:q].strip rescue ''
    set_site_title("#{I18n.t('search.search')}『#{@keyword}』")
    @tracks = Track.requestable.randomize.page(page)
    render action: 'search'
  end

  def history
    set_site_title(I18n.t('navbar.history'))
    @histories = History.includes(:track).order(id: :desc).page(page).load
  end

  def latest
    set_site_title(I18n.t('navbar.latest'))
    @tracks = Track.requestable.where(Track.arel_recent_tracks).order(id: :desc).page(page)
  end

  private
  def search_params
    query_params = params[:q]
    {
      tags_or_artist_or_title_or_album_eq: query_params,
      tags_or_artist_or_title_or_album_cont_all: query_params.split(/\s+/),
      asin_or_niconico_or_szhash_or_uploader_eq: query_params,
      m: 'or'
    }
  end
end
