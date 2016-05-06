require 'coderayify'

module ApplicationHelper
  def google_fonts_link_tag(family, *sources)
    link = {:rel => :stylesheet, :href => "//fonts.googleapis.com/css?family=#{CGI::escape(family)}"}
    sources.each do |source|
      source.each do |key, value|
        link[key] = value
      end
    end
    tag 'link', link, false, false
  end

  def i18n_list_tag(name, i18n_name, options = nil)
    list_array = t(i18n_name).split("\n").map { |line| content_tag :li, sanitize(line, attributes: %w(href target)) }
    content_tag name, list_array.join.html_safe, options
  end

  def tripcode(address)
    address.gsub(/\.[0-9]+\.[0-9]+$/, '.' + Zlib::crc32(address).to_s(16).rjust(8, '0').slice(4..7)).upcase
  end

  def dummy_text_field_tags(name = nil, content = nil)
    spantext = content_tag :span, content, class: 'js-spantext editable'
    inputtext = text_field_tag name, content, class: 'js-inputtext hidden'
    spantext + inputtext
  end

  def simple_content(text, options = {})
    options = options.symbolize_keys
    content_tag :p, html_escape(text).gsub(/(?:\n\r?|\r\n?)/, '<br />').html_safe, options
  end

  def markdown_format(text, options = {})
    markdown_html = markdown_render(text)
    content_tag :div, markdown_html, options
  end

  # %F - The ISO 8601 date format (%Y-%m-%d)
  # %R - 24-hour time (%H:%M)
  # %T - 24-hour time (%H:%M:%S)
  def date_tag(date_or_time)
    return nil if date_or_time.nil?
    time_tag date_or_time, format: '%F'
  end

  def datetime_tag(date_or_time)
    return nil if date_or_time.nil?
    time_tag date_or_time, format: '%F %R'
  end

  def render_flash_messages
    render partial: 'partials/flash_messages'
  end

  def render_object_error_messages(object)
    render partial: 'partials/object_error_messages', :locals => {object: object}
  end

  def render_navbar_list
    render partial: 'partials/navbar_list'
  end

  def render_navbar_list_member
    return unless @access > 0
    render partial: 'partials/navbar_list_member'
  end

  def render_redirect_to_hidden_field_tag(redirect_to)
    return nil if redirect_to.nil?
    hidden_field_tag 'redirect_to', redirect_to
  end

  def render_pagination(object)
    content_tag :div, paginate(object, remote: true), class: 'clearfix'
  end

  def render_debug_information
    return nil
    render partial: 'partials/debug_information'
  end

  def navbar_items
    [
      {url: news_path,         text: t('navbar.news'),     link_options: {remote: true}},
      {url: search_path,       text: t('navbar.search'),   link_options: {remote: true}},
      {url: category_path,     text: t('navbar.category'), link_options: {remote: true}},
      {url: root_catalog_path, text: t('navbar.catalog'),  link_options: {remote: true}},
      {url: history_path,      text: t('navbar.history'),  link_options: {remote: true}},
      {url: latest_path,       text: t('navbar.latest'),   link_options: {remote: true}},
      {url: upload_path,       text: t('navbar.upload'),   link_options: {remote: true}},
      {url: images_path,       text: t('navbar.images'),   link_options: {remote: true}},
      {url: chat_path,         text: t('navbar.chat'),     link_options: {remote: true}},
      {url: faq_path,          text: t('navbar.faq'),      link_options: {remote: true}},
      {url: issues_path,       text: t('navbar.feedback'), link_options: {remote: true}},
      {url: '/phate.m3u',      text: 'phate.m3u'}
    ]
  end

  def navbar_member_items
    [
      {url: admin_notices_path,          text: t('admin.notices.notification_management'),            privilege: 5},
      {url: admin_images_path,           text: t('admin.images.background_management'),               privilege: 5},
      {url: admin_playlist_index_path,   text: t('admin.playlist.playlist_management'),               privilege: 5},
      {url: admin_tracks_path,           text: t('admin.track.track_management'),                     privilege: 5},
      {url: admin_track_migrations_path, text: t('admin.track_migration.track_migration_management'), privilege: 5},
      {url: logout_path,                 text: t('members.logout'),                                   privilege: 0}
    ]
  end
end
