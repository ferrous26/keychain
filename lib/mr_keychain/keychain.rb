module Keychain

  class << self

    ##
    # @note This method asks only for the metadata and should never need
    #       user authorization.
    #
    # Returns true if there is at least one item matching the given
    # attributes and search parameters.
    #
    # This method provides a default class, and enforces a return type
    # and match limit; the default key/value pairs:
    #
    # * KSecClass            => KSecClassInternetPassword
    # * KSecMatchLimit       => KSecMatchLimitOne
    # * KSecReturnAttributes => true
    #
    # The class can be overridden, but the match limit and return type
    # cannot. You can add as many attributes and/or search parameters
    # as you like, they are listed under "Attribute Item Keys and
    # Values" or "Search Keys" in Apple's documentation.
    #
    # @param [Hash] search_dict
    # @raise [KeychainException] only for unexpected result codes
    def item_exists? search_dict
      dict = create_search_dict( { KSecClass => KSecClassInternetPassword },
                                 { KSecMatchLimit => KSecMatchLimitOne },
                                 search_dict,
                                 KSecReturnAttributes )

      result     = Pointer.new(:id)
      error_code = SecItemCopyMatching( dict, result )

      case error_code
      when ErrSecSuccess      then true
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
    def item search_dict
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


    private

    def create_search_dict override, enforce, user, return_type
      dict = override.merge(user).merge(enforce)
      for key in [KSecReturnAttributes, KSecReturnData, KSecReturnRef, KSecReturnPersistentRef]
        dict.delete key
      end
      dict.merge!( return_type => true )
    end

  end

end
