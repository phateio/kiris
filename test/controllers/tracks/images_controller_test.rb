require 'test_helper'

class Tracks::ImagesControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, track_id: 1
    assert_response :success
    assert_not_nil assigns(:image)
    assert_not_nil assigns(:images)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end
end
