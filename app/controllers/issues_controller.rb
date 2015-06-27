require 'metacharacters'

class IssuesController < ApplicationController
  before_filter :filter_admin_info!
  before_action :load_internal_style_sheet!
  helper_method :get_issue_serial
  helper_method :thread_editable?
  helper_method :reply_editable?

  def get_issue_serial(id)
    "%03d" % id.to_i
  end

  def thread_editable?(item)
    @access > 0
  end

  def reply_editable?(item_reply)
    @access > 0 || item_reply[:userip] == @client[:ip]
  end

  def index
    set_site_title(I18n.t('issues.list_of_issues'))

    @items = []
    issues = Issue.where(status: 'OPEN').order(id: :desc)

    issues.each do |issue|
      nickname = issue.nickname.strip_unicode_control_characters
      @items << {id: issue.id,
                 dateline: issue.dateline,
                 subject: issue.subject,
                 message: issue.message,
                 nickname: nickname,
                 useragent: issue.useragent,
                 userip: issue.userip,
                 typeid: issue.typeid,
                 status: issue.status,
                 identity: issue.identity,
                 rate: issue.rate}
    end
  end

  def new
    set_site_title(I18n.t('issues.new_issue'))
    @typeids ||= ['question', 'suggestion', 'appeal']
  end

  def create
    set_site_title(I18n.t('issues.new_issue'))
    @typeids ||= ['question', 'suggestion', 'appeal']

    dateline = Time.now.utc
    subject = request.POST[:subject].to_s.strip
    message = request.POST[:message].to_s.strip
    nickname = request.POST[:nickname].to_s.strip
    useragent = @client[:useragent]
    userip = @client[:ip]
    typeid = request.POST[:typeid]

    @subject = subject
    @message = message

    if subject.length == 0
      flash.now[:error] = I18n.t('issues.title_cannot_be_empty')
      render action: 'new'
      return
    end

    if message.length == 0
      flash.now[:error] = I18n.t('issues.content_cannot_be_empty')
      render action: 'new'
      return
    end

    if not @typeids.include?(typeid)
      flash.now[:error] = I18n.t('issues.typeid_invalid')
      render action: 'new'
      return
    end

    issue = Issue.create!(dateline: dateline,
                          subject: subject,
                          message: message,
                          nickname: nickname,
                          useragent: useragent,
                          userip: userip,
                          typeid: typeid,
                          status: 'OPEN',
                          identity: @identity)

    SystemMailer.new_issue_notify(subject, message, nickname).deliver

    x_redirect_to action: 'show', id: issue.id
  end

  def show
    @item = {}
    @item_replies = []
    id = params[:id]
    issue = Issue.where(id: id).first

    set_site_title("#{I18n.t('issues.issue')}##{get_issue_serial(id)}")

    if issue
      nickname = issue.nickname.strip_unicode_control_characters
      @item = {id: issue.id,
               dateline: issue.dateline,
               subject: issue.subject,
               message: issue.message,
               nickname: nickname,
               useragent: issue.useragent,
               userip: issue.userip,
               typeid: issue.typeid,
               status: issue.status,
               identity: issue.identity,
               rate: issue.rate}
    end

    issue_replies = IssueReply.where(issue_id: id).order(id: :asc)

    issue_replies.each do |issue_reply|
      nickname = issue_reply.nickname.strip_unicode_control_characters
      @item_replies << {id: issue_reply.id,
                        dateline: issue_reply.dateline,
                        message: issue_reply.message,
                        nickname: nickname,
                        useragent: issue_reply.useragent,
                        userip: issue_reply.userip,
                        status: issue_reply.status,
                        identity: issue_reply.identity,
                        rate: issue_reply.rate}
    end
  end

  def append
    id = params[:id]
    issue = Issue.where(id: id).first

    dateline = Time.now.utc
    message = request.POST[:message].to_s.strip
    nickname = request.POST[:nickname].to_s.strip
    useragent = @client[:useragent]
    userip = @client[:ip]

    if not issue
      x_redirect_to action: 'show', id: id
    end

    set_site_title("#{I18n.t('issues.issue')}##{get_issue_serial(issue.id)}")

    if message.length > 0
      IssueReply.create!(issue_id: issue.id,
                         dateline: dateline,
                         message: message,
                         nickname: nickname,
                         useragent: useragent,
                         userip: userip,
                         status: 'NORMAL',
                         identity: @identity,
                         rate: 0)

      subject = issue.subject
      puts subject
      SystemMailer.new_issue_reply_notify(subject, message, nickname).deliver
    else
      flash[:error] = I18n.t('issues.content_cannot_be_empty')
    end

    x_redirect_to action: 'show', id: issue.id
  end

  def update
    id = params[:id]

    issue_id = request.POST[:issue_id].to_i
    issue_status = request.POST[:issue_status].to_s
    reply_id = request.POST[:reply_id].to_i
    message = request.POST[:message].to_s.strip
    nickname = request.POST[:nickname].to_s.strip

    if issue_id > 0
      issue = Issue.where(id: issue_id).first
      if issue && thread_editable?(issue)
        case issue_status
        when 'OPEN', 'CLOSED'
          issue.update_attributes!(status: issue_status)
        else
          issue.update_attributes!(message: message)
        end
        issue.save!
      end
    end

    if reply_id > 0
      issue_reply = IssueReply.where(id: reply_id).first
      if issue_reply && reply_editable?(issue_reply)
        issue_reply.update_attributes!(message: message)
        issue_reply.save!
      end
    end

    x_redirect_to action: 'show', id: id
  end

  def destroy
    id = params[:id]

    issue_id = request.POST[:issue_id].to_i
    reply_id = request.POST[:reply_id].to_i

    if issue_id > 0
      issue = Issue.where(id: issue_id).first
      if issue && thread_editable?(issue)
        issue.destroy
      end
    end

    if reply_id > 0
      issue_reply = IssueReply.where(id: reply_id).first
      if issue_reply && reply_editable?(issue_reply)
        issue_reply.destroy
      end
    end

    x_redirect_to action: 'show', id: id
  end
end
