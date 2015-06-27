require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
