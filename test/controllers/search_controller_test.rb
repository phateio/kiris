require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_select 'title', /^((?!translation missing:).)+$/i
  end

  test 'search' do
    get :index, q: 'keyword'
    assert_response :success
    assert_not_nil assigns(:tracks)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end

  test 'history' do
    get :history
    assert_response :success
    assert_not_nil assigns(:histories)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end

  test 'latest' do
    get :latest
    assert_response :success
    assert_not_nil assigns(:tracks)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end
end
