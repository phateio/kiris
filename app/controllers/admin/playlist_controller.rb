require 'resolv'

class Admin::PlaylistController < ApplicationController
  before_action :load_internal_style_sheet!
  before_action :authenticate

  def index
    set_site_title(I18n.t('admin.playlist.title'))
    @playlist_colle = Playlist.includes(:track).order(playedtime: :desc, id: :asc).page(page)
  end

  def new
    set_site_title(I18n.t('admin.playlist.title'))
    @playlist = Playlist.new
  end

  def create
    set_site_title(I18n.t('admin.playlist.title'))
    @playlist = Playlist.new(playlist_params)
    render 'new' and return if not @playlist.save
    x_redirect_to admin_playlist_index_path
  end

  def edit
    set_site_title(I18n.t('admin.playlist.title'))
    @playlist = Playlist.find(playlist_id)
  end

  def update
    set_site_title(I18n.t('admin.playlist.title'))
    @playlist = Playlist.find(playlist_id)
    render 'edit' and return if not @playlist.update(playlist_params)
    x_redirect_to admin_playlist_index_path
  end

  def destroy
    @playlist = Playlist.find(playlist_id)
    @playlist.destroy
    x_redirect_to admin_playlist_index_path
  end

  private
  def playlist_id
    params[:id]
  end

  def playlist_params
    params.require(:playlist).permit!
  end
end
