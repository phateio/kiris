require 'test_helper'

class Admin::ImagesControllerTest < ActionController::TestCase
  test 'admin images index' do
    get :index
    assert_response :forbidden

    authenticate_member
    get :index
    assert_response :success
    assert_not_nil assigns(:images)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
