framework 'Security'

# Classes, modules, methods, and constants relevant to working with the
# Mac OS X keychain.
module Keychain

# Represents an entry in keychain.
class Item

  # @return [Hash]
  attr_accessor :attributes

  # You should initialize objects of this class with the attributes relevant
  # to the item you wish to work with, but you can add or remove attributes
  # via accessors as well.
  # @param [Hash] attributes
  def initialize attributes = nil
    @attributes = attributes
  end

end

end
