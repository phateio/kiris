class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :username, null: false, default: ''
      t.string :password, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.integer :access, null: false, default: 0
      t.timestamp :lastact, null: false, default: Time.at(0).utc
      t.timestamps
    end

    add_index :members, :identity
  end
end
