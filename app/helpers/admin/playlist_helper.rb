module Admin::PlaylistHelper
  def render_admin_playlist_form(playlist, form_for_option_url)
    render partial: 'playlist_form', :locals => {playlist: playlist, form_for_option_url: form_for_option_url}
  end

  def render_admin_playlist_list(playlist_colle)
    render partial: 'playlist_list', :locals => {playlist_colle: playlist_colle}
  end

  def render_admin_playlist_list_item(playlist)
    render partial: 'playlist_list_item', :locals => {playlist: playlist}
  end

  def render_admin_playlist_list_item_header
    render partial: 'playlist_list_item_header'
  end

  def render_admin_playlist_hostname(address)
    return nil if address.empty?
    @dns.getname(address).to_s rescue address
  end

  def render_admin_playlist_edit_link(playlist)
    link_to t('form.edit'), edit_admin_playlist_path(playlist), remote: true
  end

  def render_admin_playlist_delete_link(playlist)
    confirm_message = 'Are you sure you want to delete this playlist?'
    link_to t('form.delete'), admin_playlist_path(playlist), method: :delete, remote: true, data: {confirm: confirm_message}
  end
end
