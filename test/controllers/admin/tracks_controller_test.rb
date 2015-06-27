require 'test_helper'

class Admin::TracksControllerTest < ActionController::TestCase
  test 'admin tracks index' do
    get :index
    assert_response :forbidden

    authenticate_member
    get :index
    assert_response :success
    assert_not_nil assigns(:tracks)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
