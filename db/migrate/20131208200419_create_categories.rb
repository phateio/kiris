class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :gid, null: false, default: 0
      t.integer :tid, null: false, default: 0
      t.string :title, null: false, default: ''
      t.string :keyword, null: false, default: ''
      t.string :comment, null: false, default: ''
      t.timestamps
    end
  end
end
