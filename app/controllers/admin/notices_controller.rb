class Admin::NoticesController < ApplicationController
  before_action :load_internal_style_sheet!
  before_action :authenticate

  def index
    set_site_title(I18n.t('admin.notices.notification_management'))
    @notices = Notice.order(dateline: :desc, id: :desc)
  end

  def update
    set_site_title(I18n.t('admin.notices.notification_management'))

    ids = request.POST[:id].to_a
    datelines = request.POST[:dateline].to_a
    subjects = request.POST[:subject].to_a
    messages = request.POST[:message].to_a
    referer = request.headers['X-XHR-Referer']

    if ids.size != datelines.size || ids.size != subjects.size || ids.size != messages.size
      flash.now[:error] = I18n.t('form.invalid_parameters')
      render action: 'index'
      return
    end

    ActiveRecord::Base.transaction do
      start_time = Time.now.utc
      ids.zip(datelines, subjects, messages) do |id, dateline, subject, message|
        case id
        when ''
          notice = Notice.create!(dateline: dateline,
                                  subject: subject,
                                  message: message)
        else
          notices = Notice.where(id: id)
          notices.each do |notice|
            notice.update_attributes(dateline: dateline,
                                     subject: subject,
                                     message: message)
            notice.save!
          end
        end
      end
      Notice.where(subject: '').destroy_all
    end

    if not referer
      redirect_to action: 'index'
      return
    end
    response.headers['X-XHR-Redirected-To'] = url_for action: 'index'
    render nothing: true
  end
end
