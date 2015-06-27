class String
  def strip_unicode_control_characters
    self.gsub(/[\u200E-\u200F\u202A-\u202E]/, '~')
  end

  def escape_sql_wildcard_characters
    self.gsub('%', '\%').gsub('_', '\_')
  end
end
