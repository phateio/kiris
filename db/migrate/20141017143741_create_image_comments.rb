class CreateImageComments < ActiveRecord::Migration
  def change
    create_table :image_comments do |t|
      t.integer :image_id, null: false, default: 0
      t.text :message, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :rate, null: false, default: 0
      t.timestamps
    end

    add_index :image_comments, :image_id
  end
end
