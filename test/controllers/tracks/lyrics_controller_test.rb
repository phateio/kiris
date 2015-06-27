require 'test_helper'

class Tracks::LyricsControllerTest < ActionController::TestCase
  test 'show' do
    assert_raises ActiveRecord::RecordNotFound do
      get :show, track_id: 1, id: 1
    end
  end
end
