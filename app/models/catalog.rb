class Catalog < ActiveRecord::Base
  has_one    :next_catalog, class_name: 'catalog', foreign_key: 'parent_id'
  belongs_to :prev_catalog, class_name: 'catalog', primary_key: 'parent_id'

  def safe_html
    self.html.html_safe
  end
end
