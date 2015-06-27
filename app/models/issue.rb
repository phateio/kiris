class Issue < ActiveRecord::Base
  has_many :issue_replies, dependent: :destroy, foreign_key: 'issue_id'
end
