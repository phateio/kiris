module Admin::TrackMigrationsHelper
  def render_admin_track_migration_form(track_migration, form_for_option_url)
    render partial: 'track_migration_form', :locals => {track_migration: track_migration, form_for_option_url: form_for_option_url}
  end

  def render_admin_track_migration_list(track_migrations)
    render partial: 'track_migration_list', :locals => {track_migrations: track_migrations}
  end

  def render_admin_track_migration_list_item(track_migration)
    render partial: 'track_migration_list_item', :locals => {track_migration: track_migration}
  end

  def render_admin_track_migration_list_item_header
    render partial: 'track_migration_list_item_header'
  end

  def render_admin_track_migration_edit_link(track_migration)
    link_to t('form.edit'), edit_admin_track_migration_path(track_migration), remote: true
  end

  def render_admin_track_migration_migrate_link(track_migration)
    link_to 'Migrate', migrate_admin_track_migration_path(track_migration), remote: true
  end

  def render_admin_track_migration_delete_link(track_migration)
    confirm_message = 'Are you sure you want to delete this track migration?'
    link_to t('form.delete'), admin_track_migration_path(track_migration), method: :delete, remote: true, data: {confirm: confirm_message}
  end

  def render_admin_track_migration_niconico_link(track_migration)
    return '-' if track_migration.niconico.nil?
    link_to track_migration.niconico, track_migration.niconico_url, target: '_blank'
  end

  def render_admin_track_migration_title(track_migration)
    track_migration_comments_link = link_to(track_migration.title, track_comments_path(track_migration), remote: true)
    track_migration_comments_size = content_tag(:span, "(#{track_migration.track_migration_comments.size})", class: 'count')
    track_migration_comments_link + track_migration_comments_size
  end
end
