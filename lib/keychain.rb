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
    @attributes = { KSecClass => KSecClassInternetPassword }
    @attributes.merge! attributes if attributes
  end

  # @note This method asks only for the metadata to be returned and thus
  #  does not need user authorization to get results.
  # Returns true if there are any item matching the given attributes.
  # @raise [KeychainException] for unexpected errors
  # @return [true,false]
  def exists?
    result = Pointer.new :id
    search = @attributes.merge({
      KSecMatchLimit       => KSecMatchLimitOne,
      KSecReturnAttributes => true
    })

    case (error_code = SecItemCopyMatching(search, result))
    when ErrSecSuccess then
      true
    when ErrSecItemNotFound then
      false
    else
      message = SecCopyErrorMessageString(error_code, nil)
      raise KeychainException, "Error checking keychain item existence: #{message}"
    end
  end

end

# A trivial exception class that exists because it has a unique name.
class KeychainException < Exception
end

end
