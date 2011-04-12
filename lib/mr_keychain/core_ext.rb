class NSMutableString
  ##
  # Returns the upper camel case version of the string. The string
  # is assumed to be in snake_case, but still works on a string that
  # is already in camel case.
  #
  # I chose to make this method update the string in place as it
  # is a fairly hot method and should perform well; by running in
  # place we save an allocation (which is slow on MacRuby right now).
  #
  # Returns nil if the string was empty.
  #
  # @return [String,nil] returns `self`
  def camelize!
    gsub! /(?:^|_)(.)/ do $1.upcase end
  end
end
