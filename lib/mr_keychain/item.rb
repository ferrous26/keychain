module Keychain

##
# @note Methods only need a user's explicit authorization if they want the
#  password data and they do not already have permission. In these cases, the OS
#  should present an alert asking to allow, deny, or always allow the script
#  to access. You need to be careful when using 'always allow' if you are
#  running this code from interactive ruby or the regular interpreter because
#  you could accidentally allow any future script to not require permission
#  to access any password in the keychain.
#
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
  # Each Keychain::Item should contain a type class (internet password,
  # generic password, etc.), and the attributes of the item. It is highly
  # recommended to not cache the password in an instance.
  # @param [Hash] attributes
  def initialize attributes = {}
    @attributes = attributes
  end

  # @note We ask for an NSData object here in order to get the password.
  # @note Blank passwords should come back as an empty string, but that
  #  hasn't been tested.
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

  # @todo This method does not really fit with the rest of the API.
  # @note This method does not need authorization unless you are
  #  updating the password.
  # Updates attributes of the item in the keychain. If the item does not
  # exist yet then this method will raise an exception.
  #
  # Use a value of nil to remove an attribute.
  # @param [Hash] new_attributes the attributes that you want to update
  # @return [Hash] attributes
  def update! new_attributes
    result = Pointer.new :id
    query  = @attributes.merge( KSecMatchLimit => KSecMatchLimitOne )

    case (error_code = SecItemUpdate(query, new_attributes))
    when ErrSecSuccess then
      metadata!
    else
      raise KeychainException.new( 'Updating keychain item', error_code )
    end
  end

  # Get all the metadata about a keychain item, they will be keyed
  # according Apple's documentation.
  # @raise [KeychainException]
  # @return [Hash]
  def metadata
    result = Pointer.new :id
    search = @attributes.merge(
      KSecMatchLimit       => KSecMatchLimitOne,
      KSecReturnAttributes => true
    )

    case (error_code = SecItemCopyMatching(search, result))
    when ErrSecSuccess then
      result[0]
    else
      raise KeychainException.new( 'Getting metadata', error_code )
    end
  end

  # Update attributes to include all the metadata from the keychain.
  # @raise [KeychainException]
  # @return [Hash]
  def metadata!
    @attributes = metadata
  end

end

end
