require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  test 'robots' do
    get :robots, format: '.txt'
    assert_response :success
  end
end
