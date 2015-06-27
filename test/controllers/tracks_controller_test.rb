require 'test_helper'

class TracksControllerTest < ActionController::TestCase
  test 'track show' do
    assert_raises ActiveRecord::RecordNotFound do
      get :show, id: 1
    end
    #assert_response :success
    #assert_not_nil assigns(:track)
    #assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
