require 'test_helper'

class CatalogsControllerTest < ActionController::TestCase
  setup do
    @catalog = catalogs(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    # assert_not_nil assigns(:catalog)
    assert_not_nil assigns(:track_groups)
    # puts @response.body
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end

  test 'should get new' do
    get :edit_or_new
    assert_response :success
    assert_not_nil assigns(:catalog)
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end

  test 'should create catalog' do
    assert_difference('Catalog.count') do
      patch :update_or_create, catalog: {
        text: '#NEW',
        updated_at: @catalog.updated_at
      }
    end
    assert_redirected_to root_catalog_path
  end

  test 'should not create catalog' do
    assert_no_difference('Catalog.count') do
      patch :update_or_create, catalog: {
        text: '#MODIFIED',
        updated_at: @catalog.updated_at + 30.minutes
      }
    end
    assert_response :success
    assert_select 'title', /^.+$/
    assert_select 'html', /^((?!translation missing:).)+$/i
  end

  test 'should update catalog' do
    catalog_old = Catalog.create!(
      text: '#NEW',
      ipaddress: request.ip
    )
    assert_no_difference('Catalog.count') do
      patch :update_or_create, catalog: {
        text: '#UPDATE',
        updated_at: catalog_old.updated_at
      }
    end
    assert_redirected_to root_catalog_path
  end
end
