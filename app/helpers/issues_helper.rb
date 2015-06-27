module IssuesHelper
  def get_author_with_tripcode(nickname, userip)
    suffix = userip.empty? ? 'Member' : tripcode(userip)
    "#{nickname}†#{suffix}"
  end

  def get_author_with_tripcode_and_admin_address_peek_column(item)
    if @access >= 5
      content_tag :li, get_author_with_tripcode(item[:nickname], item[:userip]), data: {tooltips_text: item[:userip]}
    else
      content_tag :li, get_author_with_tripcode(item[:nickname], item[:userip])
    end
  end

  def render_dateline(item)
    render partial: 'dateline', :locals => {item: item}
  end

  def render_issue_list(items)
    render partial: 'issue_list', :locals => {items: items}
  end

  def render_issue_thread(item)
    render partial: 'issue_thread', :locals => {item: item}
  end

  def render_issue_thread_action(item)
    render partial: 'issue_thread_action', :locals => {item: item}
  end

  def render_issue_thread_edit_zone(item)
    render partial: 'issue_thread_edit_zone', :locals => {item: item}
  end

  def render_issue_thread_open_zone(item)
    render partial: 'issue_thread_open_zone', :locals => {item: item}
  end

  def render_issue_thread_close_zone(item)
    render partial: 'issue_thread_close_zone', :locals => {item: item}
  end

  def render_issue_thread_delete_zone(item)
    render partial: 'issue_thread_delete_zone', :locals => {item: item}
  end

  def render_issue_replies(item_replies)
    render partial: 'issue_replies', :locals => {item_replies: item_replies}
  end

  def render_issue_reply_action(item_reply)
    render partial: 'issue_reply_action', :locals => {item_reply: item_reply}
  end

  def render_issue_reply_edit_zone(item_reply)
    render partial: 'issue_reply_edit_zone', :locals => {item_reply: item_reply}
  end

  def render_issue_reply_delete_zone(item_reply)
    render partial: 'issue_reply_delete_zone', :locals => {item_reply: item_reply}
  end

  def render_issue_form(typeids, subject, message)
    render partial: 'issue_form', :locals => {typeids: typeids,
                                              subject: subject,
                                              message: message}
  end

  def render_issue_reply_form(item)
    render partial: 'issue_reply_form', :locals => {subject: item[:subject]}
  end
end
