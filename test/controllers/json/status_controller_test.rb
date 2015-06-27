require 'test_helper'

class Json::StatusControllerTest < ActionController::TestCase
  test 'json status index' do
    get :index, format: 'json'
    assert_response :success
  end
end
