class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.text    :text,      null: false, default: ''
      t.text    :html,      null: false, default: ''
      t.string  :comment,   null: false, default: ''
      t.string  :nickname,  null: false, default: ''
      t.string  :ipaddress, null: false, default: ''
      t.string  :forwarded, null: false, default: ''
      t.string  :useragent, null: false, default: ''
      t.string  :sessionid, null: false, default: ''
      t.integer :length,    null: false, default: 0
      t.string  :revision,  null: false, default: ''
      t.integer :parent_id, null: false, default: 0
      t.timestamps null: false
    end
  end
end
