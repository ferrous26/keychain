module Keychain

##
# @note Only the {#password} method should ever cause an alert to pop up
#       and require permission, and this should only happen for keychain
#       items that were not created using the same program that is asking
#       for the password.
#
# Represents an entry in the login keychain.
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

  ##
  # Each Keychain::Item should contain a KSecClass at the very least; the
  # default value is KSecClassInternetPassword.
  #
  # @param [Hash] attributes
  def initialize attributes = {}
    @attributes = { KSecClass => KSecClassInternetPassword }.merge(attributes)
  end

  ##
  # @note Blank passwords should come back as an empty string, but that
  #       hasn't been tested thoroughly.
  #
  # Returns the password for the item.
  #
  # This method will raise an error if no keychain item is found, which
  # should only happen if the item was deleted since this object was
  # instantiated or you changed some of the key/value pairs used to
  # lookup the object.
  # @raise [Keychain::KeychainException]
  # @return [String] UTF8 encoded password string
  def password
    search = @attributes.merge(
      KSecMatchLimit => KSecMatchLimitOne,
      KSecReturnData => true
    )
    result = Pointer.new :id

    case error_code = SecItemCopyMatching( search, result )
    when ErrSecSuccess then
      result[0].to_str
    else
      raise KeychainException.new( 'Getting password', error_code )
    end
  end


  # Updates the password associated with the keychain item. If the item does
  # not exist in the keychain it will be added first.
  # @raise [KeychainException]
  # @param [String] new_password a UTF-8 encoded string
  # @return [String] the saved password
  def password= new_password
    password_data = { KSecValueData => new_password.to_data }
    if exists?
      error_code = SecItemUpdate( @attributes, password_data )
    else
      error_code = SecItemAdd( @attributes.merge password_data, nil )
    end

    case error_code
    when ErrSecSuccess then
      password
    else
      raise KeychainException.new( 'Updating password', error_code )
    end
  end

  def account
    attributes[KSecAttrAccount]
  end

  def account= value
    attributes[KSecAttrAccount] = value
  end

  def server
    attributes[KSecAttrServer]
  end

  def server= value
    attributes[KSecAttrServer] = value
  end

end
end
