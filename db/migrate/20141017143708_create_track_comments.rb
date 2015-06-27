class CreateTrackComments < ActiveRecord::Migration
  def change
    create_table :track_comments do |t|
      t.integer :track_id, null: false, default: 0
      t.text :message, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :rate, null: false, default: 0
      t.timestamps
    end

    add_index :track_comments, :track_id
  end
end
