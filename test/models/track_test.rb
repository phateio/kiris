require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  track_szhash = 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
  track_niconico = 'sm9'
  track_title = 'レッツゴー！陰陽師'
  track_status_ok = 'OK'

  test 'validations' do
    assert Track.create(title: track_title).valid?
    assert Track.create(title: track_title, niconico: track_niconico).valid?
    assert Track.create(title: track_title, status: track_status_ok, szhash: track_szhash, niconico: track_niconico).valid?

    assert_not Track.create.valid?
    assert_not Track.create(niconico: track_niconico).valid?
    assert_not Track.create(title: track_title, status: track_status_ok).valid?
    assert_not Track.create(title: track_title, status: track_status_ok, szhash: '').valid?
    assert_not Track.create(title: track_title, status: track_status_ok, szhash: track_szhash, niconico: "#{track_niconico};").valid?
  end
end
