module Admin::NoticesHelper
  def render_notice_form(notices)
    render partial: 'notice_form', :locals => {notices: notices}
  end

  def render_notice_list(notices)
    render partial: 'notice_list', :locals => {notices: notices}
  end

  def render_notice_template
    render partial: 'notice_template'
  end
end
