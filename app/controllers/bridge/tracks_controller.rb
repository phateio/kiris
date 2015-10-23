class Bridge::TracksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  layout false

  def index
    @items = []
    unless params[:type]
      render nothing: true, status: :not_found and return
    end
    case params[:type]
    when 'empty_niconico'
      search_empty_niconico
    when 'szhash'
      search_by_szhash
    else
      render nothing: true, status: :not_found and return
    end
    respond_to do |format|
      format.xml { render xml: @items }
      format.json { render json: @items }
    end
  end

  def search_empty_niconico
    tracks = Track.where.not(niconico: '').where(szhash: '').order(id: :asc)
    tracks.each do |track|
      @items << track_item(track)
    end
  end

  def search_by_szhash
    szhash = request.GET[:szhash]
    tracks = Track.where(szhash: szhash).order(id: :asc)
    tracks.each do |track|
      @items << track_item(track)
    end
  end

  def update
    @track = Track.find(track_id)
    secret_key = request.POST[:secret_key]
    if secret_key != $BRIDGE_SECRET_KEY
      render nothing: true, status: :forbidden and return
    end
    @track.update(track_params.merge(mtime: Time.now.utc))
    render nothing: true
  end

  private
    def track_id
      request.POST[:id]
    end

    def track_params
      request.POST.slice(
        :szhash,
        :duration,
        :status,
        :source_format,
        :source_bitrate,
        :source_channels,
        :source_frequency
      )
    end

    def track_item(track)
      {
        id: track.id,
        szhash: track.szhash,
        status: track.status,
        niconico: track.niconico
      }
    end
end
