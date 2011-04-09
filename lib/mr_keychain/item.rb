module Keychain

##
# @note Only the {#password} method should ever cause an alert to pop up
#       and require permission, and this should only happen for keychain
#       items that were not created using the same program that is asking
#       for the password.
#
# @todo Need to add some documentation to explain locally cached attributes
#       and how they need to be {#save!}'d in order to persist changes and
#       additions.
#
# Represents an entry in the login keychain.
#
# In order to be secure, this class will NEVER cache a password; any time
# that you change a password, it will be written to the keychain immeadiately.
class Item

  ##
  # @todo Exploit hash lookup failure blocks to do dynamic attribute lookup
  #
  # Each Keychain::Item should contain a KSecClass at the very least; the
  # default value is KSecClassInternetPassword.
  #
  # @param [Hash] attributes
  def initialize attrs = {}
    @tainted    = {}
    @attributes = { KSecClass => KSecClassInternetPassword }.merge(attrs)
  end

  # @group Accessors

  ##
  # Direct access to the attributes hash of the keychain item. You can
  # get a list of all the attributes from Apple's documentation (see the
  # README file).
  #
  # @example Get the server address
  #   @item[KSecAttrServer]
  # @example Get the account name
  #   @item[KSecAttrAccount]
  # @example Get the password
  #   @item[KSecAttrPassword]
  def [] key
    key == KSecAttrPassword ? self.password : @attributes[key]
  end

  ##
  # Direct access to the attributes hash of the keychain item. You can
  # get a list of all the attributes from Apple's documentation (see the
  # README file).
  #
  # @example Set a comment
  #   @item[KSecAttrComment] = 'my alternative account'
  # @example Set the port
  #   @item[KSecAttrPort] = 9001
  # @example Set the password
  #   @item[KSecAttrPassword] = 'raspberries'
  def []= key, value
    @tainted[key] = true unless value == @attributes[key]
    @attributes[key] = value
  end

  # @group Alternate accessors

  ##
  # Read the value of the KSecClass attribute; equivalent to
  # <tt>#[KSecClass]</tt>.
  def item_class; self[KSecClass]; end

  ##
  # Set the value of the KSecClass attribute; equivalent to
  # <tt>#[KSecClass] = value</tt>.
  def item_class= value; self[KSecClass] = value; end

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
  #
  # @raise [KeychainException] only for unexpected result codes
  # @return [String] UTF8 encoded password string
  def password
    search = @attributes.merge(
      KSecMatchLimit => KSecMatchLimitOne,
      KSecReturnData => true
    )
    result = Pointer.new(:id)

    case error_code = SecItemCopyMatching( search, result )
    when ErrSecSuccess then
      result[0].to_str
    else
      raise KeychainException.new( 'Getting password', error_code )
    end
  end

  ##
  # Updates the password associated with the keychain item. If the item does
  # not exist in the keychain it will be added first.
  #
  # @raise [KeychainException] only for unexpected result codes
  # @param [String] new_password a UTF-8 encoded string
  # @return [String] the saved password
  def password= new_password
    password_data = { KSecValueData => (new_password || '').to_data }
    error_code    = if exists?
                      SecItemUpdate( @attributes, password_data )
                    else
                      SecItemAdd( @attributes.merge(password_data), nil )
                    end
    case error_code
    when ErrSecSuccess then password_data[KSecValueData].to_str
    else raise KeychainException.new( 'Updating password', error_code )
    end
  end

  ##
  # Dynamic get/set for the various attributes that a keychain item can have.
  #
  # @param [Symbol] meth the unique part of an attribute constant
  #                      (e.g. account for KSecAttrAccount)
  def method_missing meth, *args
    method = meth.to_s
    setter = method.chomp!('=')
    method.camelize!.chomp!('?')
    ["KSecAttr#{method}", "KSecAttrIs#{method}"].each do |const|
      if Kernel.const_defined?(const)
        value = Kernel.const_get(const)
        return (setter ? self.send(:[]=, value, *args) : self[value])
      end
    end
    super
  end

  # @endgroup

  ##
  # See if the item currently exists in the keychain.
  def exists?
    Keychain.item_exists?(@attributes)
  end

  ##
  # Reload the cached item attributes from the keychain. An error
  # will be raised if the item does not exist. If more than one
  # item exists then the first one found will be reloaded.
  #
  # @raise [KeychainException] only for unexpected result codes
  # @return [Keychain::Item]
  def reload!
    new_attributes = Pointer.new(:id)
    old_attributes = @attributes.merge( KSecReturnAttributes => true,
                                        KSecMatchLimit => KSecMatchLimitOne )
    error_code     = SecItemCopyMatching(old_attributes, new_attributes)
    case error_code
    when ErrSecSuccess then @attributes = new_attributes[0]
    else raise KeychainException.new( 'Reloading keychain item', error_code )
    end
  end


end
end
