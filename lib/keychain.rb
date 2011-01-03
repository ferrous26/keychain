framework 'Foundation'

# Classes, modules, methods, and constants relevant to working with the
# Mac OS X keychain.
module Keychain

# @note Some methods require a users excplicit authorization in order to work.
#  In these cases, the OS should present an alert asking to allow, deny, or
#  always allow the script to access. You need to be careful when using
#  'always allow' if you are running this code from interactive ruby or the
#  regular interpreter because you could accidentally allow any future script
#  to not require permission to access any password in the keychain.
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

  # @todo find out what is returned for blank passwords (empty string or nil)
  # @note This method needs authorization to work because it actually looks for
  #  a password.
  # @note Since we want the password we will ask for an NSData pointer to be
  #  returned instead of a Hash of attributes.
  # Returns the password for the first match found, raises an error if
  # no keychain item is found.
  # @raise [KeychainException]
  # @return [String] UTF8 encoded password string
  def password
    result = Pointer.new :id
    search = @attributes.merge({
      KSecMatchLimit => KSecMatchLimitOne,
      KSecReturnData => true
    })

    case (error_code = SecItemCopyMatching(search, result))
    when ErrSecSuccess then
      NSString.alloc.initWithData result[0], encoding:NSUTF8StringEncoding
    else
      message = SecCopyErrorMessageString(error_code, nil)
      raise KeychainException, "Error getting password: #{message}"
    end
  end
end

# A trivial exception class that exists because it has a unique name.
class KeychainException < Exception
end

end
