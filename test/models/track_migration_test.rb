require 'test_helper'

class TrackMigrationTest < ActiveSupport::TestCase
  track_szhash = 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
  track_niconico = 'sm9'
  track_title = 'レッツゴー！陰陽師'

  test 'validations' do
    assert TrackMigration.create(title: track_title).valid?
    assert TrackMigration.create(title: track_title, szhash: track_szhash).valid?
    assert TrackMigration.create(title: track_title, szhash: track_szhash, niconico: track_niconico).valid?

    assert_not TrackMigration.create.valid?
    assert_not TrackMigration.create(niconico: "#{track_niconico};").valid?
    assert_not TrackMigration.create(szhash: track_szhash, niconico: "#{track_niconico};").valid?
  end
end
