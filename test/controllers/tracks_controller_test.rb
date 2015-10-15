require 'test_helper'

class TracksControllerTest < ActionController::TestCase
  test 'should show track' do
    get :show, id: 1
    assert_response :success
    assert_not_nil assigns(:track)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end
end
