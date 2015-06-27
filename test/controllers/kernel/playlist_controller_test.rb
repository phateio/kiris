require 'test_helper'

class Kernel::PlaylistControllerTest < ActionController::TestCase
  test 'kernel playlist index' do
    get :index, format: 'json'
    assert_response :success
  end
end
