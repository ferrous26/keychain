framework 'Foundation'

# Classes, modules, methods, and constants relevant to working with the
# Mac OS X keychain.
module Keychain

# @note Methods that actually access passwords instead of metadata require a
#  users excplicit authorization in order to work. In these cases, the OS
#  should present an alert asking to allow, deny, or always allow the script
#  to access. You need to be careful when using 'always allow' if you are
#  running this code from interactive ruby or the regular interpreter because
#  you could accidentally allow any future script to not require permission
#  to access any password in the keychain.
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
  # @note This method needs authorization.
  # @note We ask for an NSData object here in order to get the password.
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


  # @note This method does not need authorization.
  # Get all the metadata about a keychain item, they will be keyed
  # according Apple's documentation.
  # @raise [KeychainException]
  # @return [Hash]
  def metadata
    result = Pointer.new :id
    search = @attributes.merge({
      KSecMatchLimit       => KSecMatchLimitOne,
      KSecReturnAttributes => true
    })

    case (error_code = SecItemCopyMatching(search, result))
    when ErrSecSuccess then
      result[0]
    else
      message = SecCopyErrorMessageString(error_code, nil)
      raise KeychainException, "Error getting metadata: #{message}"
    end
  end

  # @note This method does not need authorization.
  # Update attributes to include all the metadata from the keychain.
  # @raise [KeychainException]
  # @return [Hash]
  def metadata!
    @attributes = metadata
  end
end

# A trivial exception class that exists to differentiate where exceptions
# are being raised.
class KeychainException < Exception
end

end
