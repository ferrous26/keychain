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

    ##
    # @note This method asks only for the metadata and should never need
    #       user authorization.
    #
    # Returns a {Keychain::Item} if an item is found, otherwise returns nil.
    #
    # The hash argument for this method is constructed exactly the same as
    # with {Keychain.item_exists?}, with the same default values given.
    #
    # @raise [KeychainException] only for unexpected result codes
    # @param [Hash] search_dict
    # @return [Keychain::Item,nil]
    def item search_dict
      dict = create_search_dict( { KSecClass => KSecClassInternetPassword },
                                 { KSecMatchLimit => KSecMatchLimitOne },
                                 search_dict,
                                 KSecReturnAttributes )

      result = Pointer.new(:id)
      error_code = SecItemCopyMatching( dict, result )

      case error_code
      when ErrSecSuccess      then Item.new(result[0])
      when ErrSecItemNotFound then nil
      else
        raise KeychainException.new( 'Looking up item', error_code )
      end
    end

    ##
    # @note This method asks only for the metadata and should never need
    #       user authorization.
    #
    # Returns an array {Keychain::Item} objects, possibly empty.
    #
    # The hash argument for this method is constructed exactly the same as
    # with {Keychain.item_exists?}, the only default key/value pair that
    # is:
    #
    # * KSecMatchLimit => KSecMatchLimitAll
    #
    # @raise [KeychainException] only for unexpected result codes
    # @param [Hash] search_dict
    # @return [Array<Keychain::Item>]
    def items search_dict
      dict = create_search_dict( { KSecClass => KSecClassInternetPassword },
                                 { KSecMatchLimit => KSecMatchLimitAll },
                                 search_dict,
                                 KSecReturnAttributes )

      result = Pointer.new(:id)
      error_code = SecItemCopyMatching( dict, result )

      case error_code
      when ErrSecSuccess      then result[0].map { |item| Item.new(item) }
      when ErrSecItemNotFound then []
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
