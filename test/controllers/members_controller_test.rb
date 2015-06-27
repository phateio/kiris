require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :forbidden

    @request.headers['X-XHR-Referer'] = ''
    get :index
    assert_response :success
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
