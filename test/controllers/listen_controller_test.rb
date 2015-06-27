require 'test_helper'

class ListenControllerTest < ActionController::TestCase
  stream_server_url = 'http://stream.phate.io/phatecc'

  test 'redirect' do
    get :redirect
    assert_redirected_to stream_server_url
    get :redirect, format: 'mp3'
    assert_redirected_to "#{stream_server_url}.mp3"
  end
end
