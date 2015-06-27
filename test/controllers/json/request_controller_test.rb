require 'test_helper'

class Json::RequestControllerTest < ActionController::TestCase
# test 'json request create' do
#   get :create, format: 'json', track_id: 1
#   assert_response :success
# end

  test 'json request create invalid track_id' do
    assert_raises ActiveRecord::RecordNotFound do
      get :create, format: 'json', track_id: 1_000_000
    end
  end
end
