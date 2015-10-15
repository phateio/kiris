require 'test_helper'

class Bridge::TracksControllerTest < ActionController::TestCase
  test 'should get not found' do
    get :index, format: 'json'
    assert_response :not_found
  end

  test 'should get empty niconico' do
    get :index, format: 'json', type: 'empty_niconico'
    assert_response :success
  end

  test 'should get empty list' do
    get :index, format: 'json', type: 'szhash'
    assert_response :success
  end

  test 'should get list' do
    get :index, format: 'json', type: 'szhash', szhash: 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    assert_response :success
  end
end
