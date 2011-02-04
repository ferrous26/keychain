require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Keychain do

  describe '.item_exists?' do

    it 'returns false if the item does not exist' do
      Keychain.item_exists?(
        KSecAttrProtocol => KSecAttrProtocolIRCS,
        KSecAttrServer   => 'github.com'
      ).should == false
    end

    it 'returns true if the item exists' do
      Keychain.item_exists?(
        KSecAttrProtocol => KSecAttrProtocolHTTPS,
        KSecAttrServer   => 'github.com'
      ).should == true
    end

    it 'raise an exception for unexpected error codes' do
      expect {
        Keychain.item_exists?(KSecClass => 'fake')
      }.to raise_exception Keychain::KeychainException
    end

    it 'should not mutate the given search dictionary' do
      search_dict = {
        KSecAttrProtocol => KSecAttrProtocolIRCS,
        KSecAttrServer   => 'github.com'
      }
      original_dict = search_dict.dup
      Keychain.item_exists? search_dict
      search_dict.should == original_dict
    end

    # I think this might be impossible to test without human intervention
    # It also passes right now even though it should not.falsely
    it 'should ignore any extra return type key/value pairs' do
      expect {
        Keychain.item_exists?(
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com',
          KSecReturnData   => true
        )
      }.to_not raise_error Keychain::KeychainException
    end

    it 'should allow for additional search attribute key/vaule pairs'
    it 'should allow the item class to be overriden'
  end


  describe '.lookup_item' do
    it 'should return nil if nothing is found' do
      result = Keychain.lookup_item(
                                    KSecAttrProtocol => KSecAttrProtocolIRCS,
                                    KSecAttrServer   => 'github.com'
                                    )
      result.should be_nil
    end

    it 'should return a single item for singular search' do
      result = Keychain.lookup_item(
                                    KSecAttrProtocol => KSecAttrProtocolHTTPS,
                                    KSecAttrServer   => 'github.com'
                                    )
      result.class.should == Keychain::Item
    end

    it 'should return an array of items for plural search' do
      result = Keychain.lookup_item(
                                    KSecMatchLimit   => KSecMatchLimitAll,
                                    KSecAttrProtocol => KSecAttrProtocolHTTPS,
                                    KSecAttrServer   => 'github.com'
                                    )
      result.class.should == Array
      result.first.class.should == Keychain::Item
    end

    it 'should allow you to override the match limit' do
      result = Keychain.lookup_item(
                                    KSecMatchLimit   => KSecMatchLimitAll,
                                    KSecAttrProtocol => KSecAttrProtocolHTTPS,
                                    )
      result.class.should == Array
    end

    it 'should ignore any extra return type key/value pairs' do
      expect {
        Keychain.lookup_item(
                             KSecAttrProtocol        => KSecAttrProtocolHTTPS,
                             KSecAttrServer          => 'github.com',
                             KSecReturnData          => true,
                             KSecReturnRef           => true,
                             KSecReturnPersistentRef => true
                             )
      }.to_not raise_error Keychain::KeychainException
    end

    it 'should not mutate the given search dictionary' do
      search_dict = {
        KSecAttrProtocol => KSecAttrProtocolIRCS,
        KSecAttrServer   => 'github.com'
      }
      original_dict = search_dict.dup
      Keychain.lookup_item search_dict
      search_dict.should == original_dict
    end

    it 'should allow for additional search attribute key/vaule pairs'
    it 'should allow the item class to be overriden'
  end

end
