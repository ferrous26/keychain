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
  def initialize attributes = {}
    @attributes = { KSecClass => KSecClassInternetPassword }.merge! attributes
  end

  # @note This method asks only for the metadata and doesn't need authorization
  # Returns true if there are any items matching the given attributes.
  # @raise [KeychainException] for unexpected errors
  # @return [true,false]
  def exists?
    result = Pointer.new :id
    search = {
      KSecMatchLimit       => KSecMatchLimitOne,
      KSecReturnAttributes => true
    }
    @attributes.each_pair { |key, value|
      if Symbol === key
        search[attr_const_get(key)] = value
      else
        search[key] = value
      end
    }

    case (error_code = SecItemCopyMatching(search, result))
    when ErrSecSuccess then
      true
    when ErrSecItemNotFound then
      false
    else
      raise KeychainException.new( 'Checking keychain item existence', error_code )
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
    search = @attributes.merge(
      KSecMatchLimit => KSecMatchLimitOne,
      KSecReturnData => true
    )

    case (error_code = SecItemCopyMatching(search, result))
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
