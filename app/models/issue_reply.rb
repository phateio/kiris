class IssueReply < ActiveRecord::Base
  belongs_to :issue, counter_cache: true
end
