class Kernel::TrackMigrationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  layout false

  def index
    items = []

    track_migrations = TrackMigration.niconico_queued_tracks.order(id: :asc)
    track_migrations.each do |track_migration|
      items << track_migration_item(track_migration)
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
    end
  end

  def update
    secret_key = request.POST[:secret_key]
    if secret_key != $KERNEL_SECRET_KEY
      render nothing: true, status: :forbidden and return
    end
    @track_migration = TrackMigration.find(track_migration_id)
    @track_migration.update(track_migration_params.merge(mtime: Time.now.utc))
    render nothing: true
  end

  def track_migration_id
    request.POST[:id]
  end

  def track_migration_params
    request.POST.slice(:szhash, :duration, :status, :source_format, :source_bitrate, :source_channels, :source_frequency)
  end

  def track_migration_item(track_migration)
    {
      id: track_migration.id,
      niconico: track_migration.niconico
    }
  end
end
