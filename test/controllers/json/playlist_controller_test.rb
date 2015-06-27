require 'test_helper'

class Json::PlaylistControllerTest < ActionController::TestCase
  test 'json playlist index' do
    get :index, format: 'json'
    assert_response :success
  end
end
