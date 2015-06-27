require 'test_helper'

class DefaultControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_template layout: 'application'
    assert_select 'title', assigns(:site_name)
    assert_select 'title', /^((?!translation missing:).)+$/i
  end

  [
    {http_accept_language: nil                                   , expected_lang: 'en'     , expected_time_zone_name: 'UTC'},
    {http_accept_language: ''                                    , expected_lang: 'en'     , expected_time_zone_name: 'UTC'},
    {http_accept_language: 'eo'                                  , expected_lang: 'en'     , expected_time_zone_name: 'UTC'},
    {http_accept_language: 'en-US,en;q=0.8'                      , expected_lang: 'en'     , expected_time_zone_name: 'Eastern Time (US & Canada)'},
    {http_accept_language: 'en-GB,en;q=0.8,en-US;q=0.6'          , expected_lang: 'en'     , expected_time_zone_name: 'London'},
    {http_accept_language: 'ko,en-US;q=0.8,en;q=0.6'             , expected_lang: 'en'     , expected_time_zone_name: 'Eastern Time (US & Canada)'},
    {http_accept_language: 'ja,en-US;q=0.8,en;q=0.6'             , expected_lang: 'ja'     , expected_time_zone_name: 'Tokyo'},
    {http_accept_language: 'ja-JP,ja,en-US;q=0.8,en;q=0.6'       , expected_lang: 'ja'     , expected_time_zone_name: 'Tokyo'},
    {http_accept_language: 'zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hans', expected_time_zone_name: 'Beijing'},
    {http_accept_language: 'zh-MY,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hans', expected_time_zone_name: 'Beijing'},
    {http_accept_language: 'zh-SG,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hans', expected_time_zone_name: 'Singapore'},
    {http_accept_language: 'zh-YUE,zh;q=0.8,en-US;q=0.6,en;q=0.4', expected_lang: 'zh-Hans', expected_time_zone_name: 'Beijing'},
    {http_accept_language: 'zh-HK,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hant', expected_time_zone_name: 'Hong Kong'},
    {http_accept_language: 'zh-MO,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hant', expected_time_zone_name: 'Beijing'},
    {http_accept_language: 'zh-TW,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hant', expected_time_zone_name: 'Taipei'},
    {http_accept_language: 'zh-tw,zh;q=0.8,en-US;q=0.6,en;q=0.4' , expected_lang: 'zh-Hant', expected_time_zone_name: 'Taipei'}
  ].each_with_index do |locale_test, index|
    test "locale detection #{index}" do
      @request.env['HTTP_ACCEPT_LANGUAGE'] = locale_test[:http_accept_language]
      get :index
      assert_select 'html[lang=?]', locale_test[:expected_lang]
      assert_equal Time.zone.name, locale_test[:expected_time_zone_name]
    end
  end
end
