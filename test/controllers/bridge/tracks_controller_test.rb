require 'test_helper'

class Bridge::TracksControllerTest < ActionController::TestCase
  test 'should get not found' do
    get :index, format: 'json'
    assert_response :not_found
  end

  test 'should get niconico_for_new list' do
    get :index, format: 'json', type: 'niconico_for_new'
    assert_response :success
  end

  test 'should get niconico_for_renew list' do
    get :index, format: 'json', type: 'niconico_for_renew'
    assert_response :success
  end

  test 'should get list' do
    get :index, format: 'json', type: 'szhash', szhash: 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    assert_response :success
  end
end
