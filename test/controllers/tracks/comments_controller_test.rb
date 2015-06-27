require 'test_helper'

class Tracks::CommentsControllerTest < ActionController::TestCase
  test 'index' do
    assert_raises ActiveRecord::RecordNotFound do
      get :index, track_id: 1, id: 1
    end
    # assert_response :not_found
    # assert_not_nil assigns(:track_migration)
    # assert_not_nil assigns(:track_migration_comment)
    # assert_not_nil assigns(:track_migration_comments)
    # assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
