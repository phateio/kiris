require 'test_helper'

class ListenControllerTest < ActionController::TestCase
  stream_server_url = 'http://stream.phate.io/phateio'

  test 'should redirect to stream server' do
    get :redirect
    assert_redirected_to "#{stream_server_url}.mp3"
    get :redirect, format: 'mp3'
    assert_redirected_to "#{stream_server_url}.mp3"
  end
end
