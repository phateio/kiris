class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :track_id, null: false, default: 0
      t.string :url, null: false, default: ''
      t.string :source, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :illustrator, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.boolean :verified, null: false, default: false
      t.integer :rate, null: false, default: 0
      t.integer :image_comments_count, null: false, default: 0
      t.timestamps
    end

    add_index :images, :track_id
  end
end
