require 'digest'

class MembersController < ApplicationController
  before_action :load_internal_style_sheet!

  def index
    set_site_title(I18n.t('members.login'))

    referer = request.headers['X-XHR-Referer']
    render file: 'public/403.html', status: :forbidden, layout: false and return if referer.nil?

    if @access > 0
      redirect_to root_path and return if referer.nil?
      response.headers['X-TOP-Redirected-To'] = root_url
      render nothing: true
    end
  end

  def login
    set_site_title(I18n.t('members.login'))

    @username = request.POST[:username]
    password = request.POST[:password]
    referer = request.headers['X-XHR-Referer']
    encrypted = Digest::SHA1.hexdigest Digest::MD5.hexdigest password
    members = Member.where(username: @username, password: encrypted).limit(1)
    identity = nil

    members.each do |member|
      session[:identity] = identity = member.identity
      session[:nickname] = member.nickname
      session[:access] = member.access
    end

    if identity.nil?
      flash.now[:error] = I18n.t('members.login_failed')
      render action: 'index'
      return
    end

    redirect_to root_path and return if referer.nil?
    response.headers['X-TOP-Redirected-To'] = root_url
    render nothing: true
  end

  def logout
    set_site_title(I18n.t('members.logout'))

    referer = request.headers['X-XHR-Referer']
    session.delete(:identity)
    session.delete(:nickname)
    session.delete(:access)

    redirect_to root_path and return if referer.nil?
    response.headers['X-TOP-Redirected-To'] = root_url
    render nothing: true
  end
end
