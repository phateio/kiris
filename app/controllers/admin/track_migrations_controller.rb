class Admin::TrackMigrationsController < ApplicationController
  before_action :load_internal_style_sheet!
  before_action :authenticate

  def index
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migrations = TrackMigration.order(id: :asc).page(page)
  end

  def new
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.new
  end

  def create
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.new(track_migration_params)
    render 'new' and return if not @track_migration.save
    x_redirect_to redirect_to_params || admin_track_migrations_path
  end

  def edit
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.find(track_migration_id)
    @redirect_to = request_referer
  end

  def update
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.find(track_migration_id)
    render 'edit' and return if not @track_migration.update(track_migration_params)
    x_redirect_to redirect_to_params || admin_track_migrations_path
  end

  def migrate
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.find(track_migration_id)
    track_min_count = Track.requestable.order(count: :asc).first.count
    @track_migration.count = track_min_count
    @track_migration.requestable!
    @track = Track.new(@track_migration.attributes.slice(*track_attribute_names))
    @redirect_to = request_referer
  end

  def transfer
    set_site_title(I18n.t('admin.track_migration.title'))
    @track_migration = TrackMigration.find(track_migration_id)
    @track = Track.new(track_params)
    @track_migration.track_migration_comments.each do |track_migration_comment|
      @track.track_comments.build(track_migration_comment.attributes.slice(*track_comment_attribute_names))
    end
    render 'migrate' and return if not @track.save
    @track_migration.destroy
    x_redirect_to redirect_to_params || admin_track_migrations_path
  end

  def destroy
    @track_migration = TrackMigration.find(track_migration_id)
    @track_migration.destroy
    x_redirect_to redirect_to_params || admin_track_migrations_path
  end

  private
  def track_migration_id
    params[:id]
  end

  def track_migration_params
    params.require(:track_migration).permit!
  end

  def track_params
    params.require(:track).permit!
  end

  def track_attribute_names
    Track.attribute_names
  end

  def track_comment_attribute_names
    TrackComment.attribute_names
  end
end
