class CreatePlaylist < ActiveRecord::Migration
  def change
    create_table :playlist do |t|
      t.timestamp :playedtime, null: false, default: Time.at(0).utc
      t.integer :track_id, null: false, default: 0
      t.string :nickname, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :aliasip, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.timestamps
    end

    add_index :playlist, :track_id
  end
end
