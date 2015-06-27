class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.timestamp :dateline, null: false, default: Time.at(0).utc
      t.string :typeid, null: false, default: ''
      t.string :subject, null: false, default: ''
      t.text :message, null: false, default: ''
      t.string :nickname, null: false, default: ''
      t.string :useragent, null: false, default: ''
      t.string :userip, null: false, default: ''
      t.string :status, null: false, default: ''
      t.string :identity, null: false, default: ''
      t.integer :rate, null: false, default: 0
      t.integer :issue_replies_count, null: false, default: 0
      t.timestamps
    end
  end
end
