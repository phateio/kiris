require 'test_helper'

class CatalogsControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:track_groups)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end
end
