framework 'Foundation'

# Classes, modules, methods, and constants relevant to working with the
# Mac OS X keychain.
module Keychain

# @note Methods only need a user's explicit authorization if they want the
#  password data, metadata does not need permission. In these cases, the OS
#  should present an alert asking to allow, deny, or always allow the script
#  to access. You need to be careful when using 'always allow' if you are
#  running this code from interactive ruby or the regular interpreter because
#  you could accidentally allow any future script to not require permission
#  to access any password in the keychain.
# Represents an entry in the login keychain.
#
# The big assumption that this class makes is that you only ever want
# to work with a single keychain item; whether it be searching for metadata,
# getting passwords, or adding a new entry.
#
# In order to be secure, this class will NEVER cache a password; any time
# that you change a password, it will be written to the keychain immeadiately.

class Item

  # @return [Hash]
  attr_accessor :attributes

  # Direct access to the attributes hash of the keychain item.
  def [] key
    @attributes[key]
  end

  # Direct access to the attributes hash of the keychain item.
  def []= key, value
    @attributes[key] = value
  end

  # You should initialize objects of this class with the attributes relevant
  # to the item you wish to work with, but you can add or remove attributes
  # via accessors as well.
  # @param [Hash] attributes
  def initialize attributes = nil
    @attributes = { KSecClass => KSecClassInternetPassword }
    @attributes.merge! attributes if attributes
  end

  # @note This method asks only for the metadata and doesn't need authorization
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

  # @note We ask for an NSData object here in order to get the password.
  # Returns the password for the first match found, raises an error if
  # no keychain item is found.
  #
  # Blank passwords should come back as an empty string, but that hasn't
  # been tested.
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


  # Updates the password associated with the keychain item. If the item does
  # not exist in the keychain it will be added first.
  # @raise [KeychainException]
  # @param [String] new_password a UTF-8 encoded string
  # @return [String] the saved password
  def password= new_password
    password_data = {
      KSecValueData => new_password.dataUsingEncoding(NSUTF8StringEncoding)
    }
    if exists?
      error_code = SecItemUpdate( @attributes, password_data )
    else
      error_code = SecItemAdd( @attributes.merge password_data, nil )
    end

    case error_code
    when ErrSecSuccess then
      password
    else
      message = SecCopyErrorMessageString(error_code, nil)
      raise KeychainException, "Error updating password: #{message}"
    end
  end

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

  # Update attributes to include all the metadata from the keychain.
  # @raise [KeychainException]
  # @return [Hash]
  def metadata!
    @attributes = metadata
  end
end

# A trivial exception class that exists to help differentiate where
# exceptions are being raised.
class KeychainException < Exception
end

end
