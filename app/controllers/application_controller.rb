class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale!
  before_action :set_timezone!
  before_action :set_headers!
  before_action :load_instance_variables!
  before_action :load_config!
  before_action :load_client!

  private
  def default_url_options
    return { host: 'localhost' } if Rails.env.development? || Rails.env.staging?
    return { host: 'test.host' } if Rails.env.test?
    { host: 'phate.io' }
  end

  def set_locale!
    I18n.locale = I18n.default_locale
    @@available_locales ||= I18n.available_locales.map(&:to_s)
    if preference_params['locale']
      locale = preference_params['locale']
      session[:locale] = locale if @@available_locales.include?(locale)
    end
    locale = sanitize_session_locale(@@available_locales) || extract_locale_from_accept_language_header(@@available_locales)
    I18n.locale = locale.to_sym if @@available_locales.include?(locale)
  end

  def set_timezone!
    if preference_params['time_zone']
      time_zone = preference_params['time_zone']
      session[:time_zone] = time_zone
    end
    time_zone = session[:time_zone] || extract_time_zone_name_from_accept_language_header
    Time.zone = time_zone
    request_start = request.env['HTTP_X_REQUEST_START']
    @start_time = request_start && Time.at(request_start.to_i / 1000).utc || Time.now.utc
  end

  def set_headers!
    expires_now if request.headers['X-XHR-Referer'] # Prevent Idiot Explorer pjax failed
    response.headers['X-UA-Compatible'] = 'IE=Edge,chrome=1'
    response.headers['X-XHR-Route'] = "#{controller_name}-#{action_name}" if request.headers['X-XHR-Referer']
  end

  def load_instance_variables!
    @dns = Resolv::DNS.new
    @dns.timeouts = 3
  end

  def load_config!
    @site_name = I18n.t('metainfo.sitename')
    @identity = session.id
    @nickname = session[:nickname]
    @access = session[:access] || 0
  end

  def load_client!
    # request.env['REMOTE_ADDR']
    # request.env['HTTP_CF_CONNECTING_IP']
    # request.ip (HTTP_X_FORWARDED_FOR)
    # request.remote_ip (HTTP_X_FORWARDED_FOR, HTTP_CLIENT_IP)

    remote_addr   = request.ip
    referer       = request.env['HTTP_REFERER']
    useragent     = request.env['HTTP_USER_AGENT']
    forwarded_ips = request.env['HTTP_X_FORWARDED_FOR']
    server_addr   = request.env['HTTP_SERVER_ADDR'] || '8.8.8.8'
    server_port   = request.env['HTTP_X_FORWARDED_PORT'] || 80

    remote_addr   = remote_addr.to_s.force_encoding('UTF-8')
    useragent     = useragent.to_s.force_encoding('UTF-8')
    forwarded_ips = forwarded_ips.to_s.force_encoding('UTF-8').split(/\s*,\s*/).last(3)
    server_addr   = server_addr.to_s.force_encoding('UTF-8')
    server_port   = server_port.to_i

    @client = {
      ip: remote_addr,
      referer: referer,
      useragent: useragent,
      forwarded_ips: forwarded_ips,
      server_addr: server_addr,
      server_port: server_port
    }
  end

  def load_internal_style_sheet!
    @subpage = true
  end

  def filter_admin_info!
    @client[:ip] = '' if @access >= 5
  end

  def set_site_title(page_name)
    @page_title = "#{page_name} - #{@site_name}"
  end

  def http_request(uri, req)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 3
    http.read_timeout = 3
    http.use_ssl = true if uri.scheme == 'https'
    http.request(req)
  end

  def http_head_response(url)
    uri = URI.parse(url)
    req = Net::HTTP::Head.new(uri.request_uri)
    res = http_request(uri, req)
    res
  end

  def http_get_response_body(url, headers = {})
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.request_uri)
    headers.each do |name, value|
      req[name] = value
    end
    res = http_request(uri, req)
    res.kind_of?(Net::HTTPSuccess) ? res.body : nil
  end

  def http_get_post_form_body(url, params = {})
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(params)
    res = http_request(uri, req)
    res.kind_of?(Net::HTTPSuccess) ? res.body : nil
  end

  def authenticate
    render file: 'public/403.html', status: :forbidden, layout: false and return unless @access >= 5
  end

  def x_redirect_to(options = {}, response_status = {})
    if request.headers['X-XHR-Referer']
      response.headers['X-XHR-Redirected-To'] = url_for(options)
      render nothing: true
    else
      redirect_to(options, response_status)
    end
    return
  end

  def page
    page_params = params[:page].to_i rescue 0
    @page = page_params > 0 ? page_params : 1
  end

  def request_referer
    return nil if request.referer.to_s.empty?
    URI(request.referer).request_uri
  end

  def redirect_to_params
    params[:redirect_to]
  end

  def preference_params
    request.POST[:preferences].to_h
  end

  def sanitize_session_locale(available_locales)
    locale = session[:locale]
    return nil if locale.nil?
    session[:locale] = nil unless available_locales.include?(locale)
    return session[:locale]
  end

  def extract_locale_from_accept_language_header(available_locales)
    # request.env['HTTP_ACCEPT_LANGUAGE'].to_s.gsub(/\-[a-z]+/, &:upcase).scan(/^[A-Za-z\-]+/).first
    chinese_locales = ['zh', 'zh-CN', 'zh-HK', 'zh-MO', 'zh-MY', 'zh-SG', 'zh-TW']
    preferred_language = http_accept_language.preferred_language_from(available_locales + chinese_locales)
    case preferred_language
    when 'zh-HK', 'zh-MO', 'zh-TW'
      return 'zh-Hant'
    when 'zh-CN', 'zh-MY', 'zh-SG', 'zh'
      return 'zh-Hans'
    end
    return preferred_language
  end

  def extract_time_zone_name_from_accept_language_header
    preferred_languages = http_accept_language.user_preferred_languages
    preferred_languages.each do |language|
      case language
      when 'en-GB'
        return 'London'
      when 'en-US', /\Aen(?:\-[A-Za-z\-]+)?\z/i
        return 'Eastern Time (US & Canada)'
      when 'ja-JP', /\Aja(?:\-[A-Za-z\-]+)?\z/i
        return 'Tokyo'
      when 'zh-SG'
        return 'Singapore'
      when 'zh-HK'
        return 'Hong Kong'
      when 'zh-TW'
        return 'Taipei'
      when 'zh-CN', /\Azh(?:\-[A-Za-z\-]+)?\z/i
        return 'Beijing'
      end
    end
    return nil
  end
end