require 'test_helper'

class Tracks::CommentsControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, track_id: 1
    assert_response :success
    assert_not_nil assigns(:track)
    assert_not_nil assigns(:track_comment)
    assert_not_nil assigns(:track_comments)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end
end
