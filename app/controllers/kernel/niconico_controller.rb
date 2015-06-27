class Kernel::NiconicoController < ApplicationController
  skip_before_filter :verify_authenticity_token

  layout false

  def index
    items = []

    tracks = Track.where.not(niconico: '').where(source_format: '').order(id: :asc)
    tracks.each do |track|
      items << track_item(track)
    end

    respond_to do |format|
      format.xml { render xml: items }
      format.json { render json: items }
    end
  end

  def update
    @track = Track.find(track_id)
    secret_key = request.POST[:secret_key]
    if secret_key != $KERNEL_SECRET_KEY
      render nothing: true, status: :forbidden and return
    end
    if @track.requestable?
      @track.update(track_safe_params.merge(mtime: Time.now.utc))
    else
      @track.update(track_params.merge(mtime: Time.now.utc))
    end
    render nothing: true
  end

  def track_id
    request.POST[:id]
  end

  def track_params
    request.POST.slice(:szhash, :duration, :status, :source_format, :source_bitrate, :source_channels, :source_frequency)
  end

  def track_safe_params
    request.POST.slice(:szhash, :duration, :source_format, :source_bitrate, :source_channels, :source_frequency)
  end

  def track_item(track)
    {
      id: track.id,
      niconico: track.niconico
    }
  end
end
