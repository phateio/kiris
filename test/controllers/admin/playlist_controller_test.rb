require 'test_helper'

class Admin::PlaylistControllerTest < ActionController::TestCase
  test 'admin playlist index' do
    get :index
    assert_response :forbidden

    authenticate_member
    get :index
    assert_response :success
    assert_not_nil assigns(:playlist_colle)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
