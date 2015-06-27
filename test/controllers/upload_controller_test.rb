require 'test_helper'

class UploadControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
