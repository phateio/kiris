require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  test 'the 404 page' do
    get :error404, foo: :api
    assert_response :not_found
  end
end
