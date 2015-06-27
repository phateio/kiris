require 'test_helper'

class Upload::NiconicoControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:tracks)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
