require 'test_helper'

class Admin::NoticesControllerTest < ActionController::TestCase
  test 'admin notices index' do
    get :index
    assert_response :forbidden

    authenticate_member
    get :index
    assert_response :success
    assert_not_nil assigns(:notices)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
