class CreateTrackMigrationComments < ActiveRecord::Migration
  def change
    create_table :track_migration_comments do |t|
      t.integer :track_migration_id, null: false, default: 0
      t.text :message, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :rate, null: false, default: 0
      t.timestamps
    end

    add_index :track_migration_comments, :track_migration_id
  end
end
