class CatalogsController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('navbar.catalog'))
    @catalog = Catalog.order(id: :desc).limit(1).first
  end

  def edit_or_new
    set_site_title(I18n.t('navbar.catalog'))
    @catalog = Catalog.order(id: :desc).limit(1).first
    @catalog ||= Catalog.new
  end

  def update_or_create
    set_site_title(I18n.t('navbar.catalog'))
    @catalog_old = Catalog.order(id: :desc).limit(1).first
    @catalog_new = Catalog.new(catalog_params)

    if @catalog_old && @catalog_old.updated_at.to_i != @catalog_new.updated_at.to_i
      @catalog_old.errors.add(:text, 'has changed before you submit')
      @catalog = @catalog_old
      render 'edit_or_new' and return
    end
    if @catalog_old && ( \
        @catalog_old.ipaddress == @client[:ipaddress] ||
        @catalog_old.sessionid == @identity.to_s
      )
      @catalog_old.attributes = {
        html: markdown_render_catalog_html(@catalog_new),
        ipaddress: @client[:ipaddress],
        forwarded: @client[:forwarded].to_s,
        useragent: @client[:useragent].to_s,
        sessionid: @identity.to_s,
        length: @catalog_new.text.split("\n").map(&:strip).length
      }
      @catalog = @catalog_old
      render 'edit_or_new' and return unless @catalog_old.update(catalog_params)
    else
      @catalog_new.attributes = {
        html: markdown_render_catalog_html(@catalog_new),
        revision: Time.now.strftime('%yw%W'),
        ipaddress: @client[:ipaddress],
        forwarded: @client[:forwarded].to_s,
        useragent: @client[:useragent].to_s,
        sessionid: @identity.to_s,
        length: @catalog_new.text.split("\n").length,
        parent_id: @catalog_old ? @catalog_old.id : 0
      }
      @catalog = @catalog_new
      render 'edit_or_new' and return unless @catalog_new.save
    end
    x_redirect_to root_catalog_path
  end

  private
    def catalog_id
      params[:id]
    end

    def catalog_params
      params.require(:catalog).permit(catalog_attribute_names)
    end

    def catalog_attribute_names
      [
        :text,
        :nickname,
        :updated_at
      ]
    end

    def track_keyword_present?(keyword)
      tracks = Track.arel_table
      Track.where(
        tracks[:tags].matches("%#{keyword}%")
        .or(tracks[:artist].matches("%#{keyword}%"))
        .or(tracks[:title].matches("%#{keyword}%"))
        .or(tracks[:album].matches("%#{keyword}%"))
      ).limit(1).size > 0
    end

    def markdown_render_catalog_html(catalog)
      catalog_html = catalog.text.split("\n").map do |line|
        line.split(',').map do |keyword|
          keyword.strip!
          if keyword.present? && track_keyword_present?(keyword)
            "[#{keyword}](/search?q=#{CGI::escape(keyword)})"
          else
            keyword
          end
        end.join(' / ')
      end.join("\n")
      markdown_render(catalog_html)
    end
end
