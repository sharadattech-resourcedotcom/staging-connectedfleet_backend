class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
  def is_f?
    true if Float(self) rescue false
  end
end