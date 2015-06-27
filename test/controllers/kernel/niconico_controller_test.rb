require 'test_helper'

class Kernel::NiconicoControllerTest < ActionController::TestCase
  test 'kernel niconico index' do
    get :index, format: 'json'
    assert_response :success
  end
end
