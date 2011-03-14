require 'spec_helper'

describe Keychain do

  describe '.item_exists?' do
    it 'returns false if the item does not exist' do
      Keychain.item_exists?( KSecAttrProtocol => KSecAttrProtocolIRCS,
                             KSecAttrServer   => 'github.com' ).should be_false
    end
    it 'returns false if there is an unexpected problem' do
      Keychain.item_exists?( KSecClass => 'fake class name' ).should be_false
    end
    it 'returns true if at least one item matches' do
      Keychain.item_exists?( KSecAttrProtocol => KSecAttrProtocolHTTPS,
                             KSecAttrServer   => 'github.com' ).should be_true
    end
    it 'returns true if there are multiple matches' do
      Keychain.item_exists?( KSecAttrProtocol => KSecAttrProtocolHTTPS ).should be_true
    end
    it 'should not mutate the given search dictionary' do
      search_dict = (original_dict = { KSecAttrServer => 'github.com' }).dup
      Keychain.item_exists? search_dict
      search_dict.should == original_dict
    end
    it 'should allow the class to be overriden'
    it 'should allow filtering based on attribute key/value pairs'
    it 'should allow filtering based on search key/value pairs'
    it 'should ignore any extra return type key/value pairs'
  end

  describe '.item' do
    it 'should return nil if nothing is found' do
      Keychain.item( KSecAttrServer => 'fake.example.org' ).should be_nil
    end
    it 'should return a single item if a single item is found' do
      ret = Keychain.item KSecAttrServer => 'github.com'
      ret.should_not be_nil
      ret.class.should == Keychain::Item
      ret[KSecAttrServer].should == 'github.com'
    end
    it 'should raise an error in case of an unexpected result code' do
      expect {
        Keychain.item( KSecClass => 'fake class name' )
      }.to raise_error Keychain::KeychainException
    end
    it 'should not mutate the given search dictionary' do
      search_dict = (original_dict = { KSecAttrServer => 'github.com' }).dup
      Keychain.item search_dict
      search_dict.should == original_dict
    end
    it 'should allow the class to be overridden'
    it 'should allow filtering based on attribute key/value pairs'
    it 'should allow filtering based on search key/value pairs'
    it 'should ignore any additional return type keys'
  end

  describe '.items' do
    it 'should return an empty array if nothing is found' do
      Keychain.items( KSecAttrServer => 'fake.example.org' ).should be_nil
    end
    it 'should return an array of one if a single item is found' do
      ret = Keychain.items KSecAttrServer => 'github.com'
      ret.should_not be_nil
      ret.class.should == Array
      ret.first[KSecAttrServer].should == 'github.com'
      ret.size.should satisfy { |size| size > 1 }
    end
    it 'should return many items if many items are found' do
      ret = Keychain.items( KSecAttrProtocol => KSecAttrProtocolHTTPS )
      ret.should_not be_nil
      ret.class.should == Array
      ret.first.class.should == Keychain::Item
      ret.first[KSecAttrProtocol].should == KSecAttrProtocolHTTPS
    end
    it 'should raise an error in case of an unexpected result code' do
      expect {
        Keychain.items( KSecClass => 'fake class name' )
      }.to raise_error Keychain::KeychainException
    end
    it 'should not mutate the given search dictionary' do
      search_dict = (original_dict = { KSecAttrServer => 'github.com' }).dup
      Keychain.items search_dict
      search_dict.should == original_dict
    end
    it 'should allow the class to be overridden'
    it 'should allow filtering based on attribute key/value pairs'
    it 'should allow filtering based on search key/value pairs'
    it 'should ignore any additional return type keys'
  end

end
