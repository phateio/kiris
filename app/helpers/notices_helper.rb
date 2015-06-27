module NoticesHelper
  def render_notice_list(notices)
    render partial: 'notice_list', :locals => {notices: notices}
  end
end
