class CreateIssueReplies < ActiveRecord::Migration
  def change
    create_table :issue_replies do |t|
      t.timestamp :dateline, null: false, default: Time.at(0).utc
      t.integer :issue_id, null: false, default: 0
      t.text :message, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :rate, null: false, default: 0
      t.timestamps
    end

    add_index :issue_replies, :issue_id
  end
end
