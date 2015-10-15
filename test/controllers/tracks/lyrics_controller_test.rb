require 'test_helper'

class Tracks::LyricsControllerTest < ActionController::TestCase
  test 'should show lyrics' do
    get :show, track_id: 1
    assert_response :success
    assert_not_nil assigns(:track)
    assert_not_nil assigns(:lyric)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end
end
