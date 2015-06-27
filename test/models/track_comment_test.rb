require 'test_helper'

class TrackCommentTest < ActiveSupport::TestCase
  track_comment_message= 'Hello World'

  test 'validations' do
    assert TrackMigrationComment.create(message: track_comment_message).valid?

    assert_not TrackMigrationComment.create.valid?
    assert_not TrackMigrationComment.create(message: '').valid?
  end
end
