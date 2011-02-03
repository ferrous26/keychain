module Keychain

  class << self

    # @note This method asks only for the metadata and doesn't need
    #  user authorization
    # Returns true if there is at least one item matching the given
    # attributes.
    #
    # Of the four types of key/value pairs that you can use when
    # generating a search dictionary, you only need to give attributes
    # in order for this method to work.
    #
    # The class this method assumes you are search for is Internet
    # Password. You can overrid this by providing a different KSecClass
    # value in the search dictionary.
    #
    # Normally, you will only need to add attributes of the keychain
    # item to the search dictionary, such as KSecAttrServer (URL) and/or
    # KSecAttrAccount (username). These are listed under "Attribute Item
    # Keys and Values" in Apple's documentation.
    #
    # Optionally, you can also add search modifying key/value pairs
    # which add other search constraints, such as case-insensitive
    # searching (KSecMatchCaseInsensitive => true). These are located
    # under the "Search Attribute Keys" section in Apple's documentation.
    #
    # Return type key/value pairs will be ignored; the only return type
    # that makes sense for this method will automatically be added.
    # @param [Hash] search_dict
    # @raise [KeychainException] only for unexpected result codes
    def item_exists? search_dict
      dict   = {
        KSecClass            => KSecClassInternetPassword
      }.merge! search_dict.merge(
        KSecMatchLimit       => KSecMatchLimitOne,
        KSecReturnAttributes => true
      )
      for key in [KSecReturnData, KSecReturnRef, KSecReturnPersistentRef]
        dict.delete key
      end
      result = Pointer.new :id # we MUST pass a pointer; nil is not allowed

      case error_code = SecItemCopyMatching( dict, result )
      when ErrSecSuccess then      true
      when ErrSecItemNotFound then false
      else
        raise KeychainException.new( 'Checking item existence', error_code )
      end
    end


    # This method is used to actually retrieve items from the keychain. The
    # interface here is almost the same as {Keychain.item_exists?} except
    # that you can override KSecMatchLimit if you want more than one result.
    #
    # This method will return nil if nothing is found; it will return a single
    # Keychain::Item if KSecMatchLimit is KSecMatchLimitOne; and will return
    # an array of Keychain::Item objects if KSecMatchLimit is KSecMatchLimitAll.
    # @param [Hash] search_dict
    # @return [Keychain::Item,Array<Keychain::Item>,nil]
    # @raise [KeychainException] only for unexpected result codes
    def lookup search_dict
      dict   = {
        KSecClass            => KSecClassInternetPassword,
        KSecMatchLimit       => KSecMatchLimitOne
      }.merge! search_dict.merge(
        KSecReturnAttributes => true
      )
      for key in [KSecReturnData, KSecReturnRef, KSecReturnPersistentRef]
        dict.delete key
      end
      result = Pointer.new :id

      case error_code = SecItemCopyMatching( dict, result )
      when ErrSecSuccess
        result = result[0]
        if result.class == Array
          result.map { |dictionary| Item.new dictionary }
        else
          Item.new result
        end
      when ErrSecItemNotFound
        return nil
      else
        raise KeychainException.new( 'Looking up item', error_code )
      end
    end

  end

end
