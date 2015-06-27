class Upload::AsinController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    #set_site_title(I18n.t('upload.asin.title'))
  end

  def show
    #set_site_title("#{I18n.t('upload.asin.title')}『#{asin_id}』")
    @items = []

    flash.now[:error] = 'invalid_amazon_asin' and return if (/^[A-Z0-9]{10}$/ =~ asin_id) == nil
    Amazon::Ecs.configure do |options|
      options[:associate_tag] = 'pharad-20'
      options[:AWS_access_key_id] = 'AKIAJEXZ37EYB5FJXSRQ'
      options[:AWS_secret_key] = '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'
    end
    res = Amazon::Ecs.item_lookup(asin_id, country: 'jp', ResponseGroup: 'Images,ItemAttributes,Tracks,AlternateVersions')
    flash.now[:error] = 'invalid_amazon_asin' and return if not res.is_valid_request?

    if res.has_error?
      puts res.error
      flash.now[:error] = 'unknow_error' and return
    end

    res.items.each do |item|
      asin = item.get('ASIN')
      detail_page_url = item.get('DetailPageURL')
      medium_image = item.get_element('ImageSets/ImageSet/MediumImage').get('URL')
      #large_image = item.get_element('ImageSets/ImageSet/LargeImage').get('URL')
      tracks = []

      item_attributes = item.get_element('ItemAttributes')
      discs = item.get_elements('Tracks/Disc')

      album_artist = item_attributes.get('Artist')
      release_date = item_attributes.get('ReleaseDate')
      album_title = item_attributes.get('Title')
      album_label = item_attributes.get('Label')

      discs.to_a.each do |disc|
        tracks = disc.get_array('Track')
      end

      alternate_versions = item.get_elements('AlternateVersions/AlternateVersion')
      alternate_versions.to_a.each do |alternate_version|
        album_title = alternate_version.get('Title') if tracks.length > 0
        break
      end

      if tracks.length == 0
        flash.now[:error] = I18n.t('tracks.album_not_found')
        return
      end

      @items << {asin: asin,
                 detail_page_url: detail_page_url,
                 album_cover: medium_image,
                 album_artist: album_artist,
                 album_title: album_title,
                 album_label: album_label,
                 release_date: release_date,
                 cover_image: nil,
                 tracks: tracks}
    end
  end

  private
  def asin_id
    #request.query_string.strip
    params[:asin_id]
  end
end
