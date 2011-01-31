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

end
