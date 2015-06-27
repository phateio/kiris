class CreateLyrics < ActiveRecord::Migration
  def change
    create_table :lyrics do |t|
      t.integer :track_id, null: false, default: 0
      t.text :text, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :version, null: false, default: 0
      t.timestamps
    end
  end
end
