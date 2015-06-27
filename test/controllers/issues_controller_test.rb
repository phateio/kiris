require 'test_helper'

class IssuesControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:items)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
