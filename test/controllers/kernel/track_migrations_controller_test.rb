require 'test_helper'

class Kernel::TrackMigrationsControllerTest < ActionController::TestCase
  test 'kernel track migrations index' do
    get :index, format: 'json'
    assert_response :success
  end
end
