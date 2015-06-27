require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  image_url = 'http://i.imgur.com/Tn4tTuZ.jpg'
  image_html5_url = '//i.imgur.com/Tn4tTuZ.jpg'
  image_thumb_url = 'http://i.imgur.com/Tn4tTuZs.jpg'
  image_source_pixiv = 'http://www.pixiv.net/member_illust.php?mode=medium&illust_id=31955940'
  image_source_piapro = 'http://piapro.jp/t/_Chy'
  image_source_seiga = 'http://seiga.nicovideo.jp/seiga/im2676375'

  test 'validations' do
    assert Image.create(url: image_url, source: '').valid?
    assert Image.create(url: image_url, source: image_source_pixiv).valid?
    assert Image.create(url: image_url, source: image_source_piapro).valid?
    assert Image.create(url: image_url, source: image_source_seiga).valid?

    assert_not Image.create.valid?
    assert_not Image.create(url: '').valid?
    #assert_not Image.create(url: image_thumb_url).valid?
    assert_not Image.create(url: image_source_pixiv).valid?
    assert_not Image.create(url: image_url, source: image_url).valid?
  end

  test 'normalize_values' do
    image = Image.create(url: "\n\t\r  #{image_url}  \r\t\n", source: "\n\t\r  #{image_source_pixiv}  \r\t\n")
    assert image.save
    assert_equal image.url, image_html5_url
    assert_equal image.source, image_source_pixiv
  end
end
