require 'test_helper'

class Admin::TrackMigrationsControllerTest < ActionController::TestCase
  test 'admin track migrations index' do
    get :index
    assert_response :forbidden

    authenticate_member
    get :index
    assert_response :success
    assert_not_nil assigns(:track_migrations)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
