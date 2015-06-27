class CreateNotices < ActiveRecord::Migration
  def change
    create_table :notices do |t|
      t.string :dateline, null: false, default: ''
      t.string :subject, null: false, default: ''
      t.string :message, null: false, default: ''
      t.timestamps
    end
  end
end
