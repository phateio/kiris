class AddScoreToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :score, :integer, null: false, default: 0
  end
end
