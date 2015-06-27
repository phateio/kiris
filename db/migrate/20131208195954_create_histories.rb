class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.timestamp :playedtime, null: false, default: Time.at(0).utc
      t.integer :track_id, null: false, default: 0
      t.timestamps
    end

    add_index :histories, :track_id
  end
end
