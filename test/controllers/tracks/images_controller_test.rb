require 'test_helper'

class Tracks::ImagesControllerTest < ActionController::TestCase
  test 'index' do
    assert_raises ActiveRecord::RecordNotFound do
      get :index, track_id: 1, id: 1
    end
  end
end
