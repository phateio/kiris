class SystemMailer < ActionMailer::Base
  def new_issue_notify(subject, message, nickname)
    @message = message
    default_from = Rails.application.config.action_mailer.default_options.to_h[:from]
    mailer_from = default_from ? "#{nickname} <#{default_from}>" : "#{nickname}"
    mailer_to = 'JRS <admin@phate.io>'
    mail from: mailer_from, to: mailer_to, subject: I18n.t('system_mailer.new_issue_notify.subject', subject: subject)
  end

  def new_issue_reply_notify(subject, message, nickname)
    @message = message
    default_from = Rails.application.config.action_mailer.default_options.to_h[:from]
    mailer_from = default_from ? "#{nickname} <#{default_from}>" : "#{nickname}"
    mailer_to = 'JRS <admin@phate.io>'
    mail from: mailer_from, to: mailer_to, subject: I18n.t('system_mailer.new_issue_reply_notify.subject', subject: subject)
  end
end
