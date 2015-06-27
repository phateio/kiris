require 'test_helper'

class TrackMigrationCommentTest < ActiveSupport::TestCase
  track_migration_comment_message= 'Hello World'

  test 'validations' do
    assert TrackMigrationComment.create(message: track_migration_comment_message).valid?

    assert_not TrackMigrationComment.create.valid?
    assert_not TrackMigrationComment.create(message: '').valid?
  end
end
