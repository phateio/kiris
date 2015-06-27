module SharedMethods
  def normalize_values
    self.attributes.each do |attribute, value|
      next if self.[](attribute).nil?
      case self.[](attribute).class.name
      when 'String'
        self.[](attribute).strip!
      end
    end
  end
end
