require 'test_helper'

class ImageCommentTest < ActiveSupport::TestCase
  image_comment_message= 'Hello World'

  test 'validations' do
    assert TrackMigrationComment.create(message: image_comment_message).valid?

    assert_not TrackMigrationComment.create.valid?
    assert_not TrackMigrationComment.create(message: '').valid?
  end
end
