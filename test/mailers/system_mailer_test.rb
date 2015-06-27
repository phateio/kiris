require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
  test "new_issue_notify" do
    mail = SystemMailer.new_issue_notify('Subject', 'Message', 'Nickname')
    assert_equal I18n.t('system_mailer.new_issue_notify.subject', subject: 'Subject'), mail.subject
    #assert_equal ['to@example.org'], mail.to
    #assert_equal ['from@example.com'], mail.from
    assert_match 'Message', mail.body.encoded
  end

  test "new_issue_reply_notify" do
    mail = SystemMailer.new_issue_reply_notify('Subject', 'Message', 'Nickname')
    assert_equal I18n.t('system_mailer.new_issue_reply_notify.subject', subject: 'Subject'), mail.subject
    #assert_equal ['to@example.org'], mail.to
    #assert_equal ['from@example.com'], mail.from
    assert_match 'Message', mail.body.encoded
  end
end
