require 'test_helper'

class NoticesControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:notices)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
