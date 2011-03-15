require 'spec_helper'

describe Keychain::Item do

  before do @item = Keychain::Item.new end

  describe 'attributes' do
    it 'is readable' do
      Keychain::Item.new.should respond_to :attributes
    end
    it 'is writable' do
      Keychain::Item.new.should respond_to :attributes=
    end
    it 'is initialized to be a hash' do
      Keychain::Item.new.attributes.class.should == Hash
    end
  end

  describe '#[]' do
    it 'should be equivalent to #attributes' do
      @item.attributes[:test] = 'test'
      @item[:test].should == 'test'
    end
    it 'should add a special case for argument KSecAttrPassword'
  end

  describe '#[]=' do
    it 'should be equivalent to #attributes=' do
      @item[:test1] = 'test'
      @item.attributes[:test1].should == 'test'
    end
    it 'should add a special case for argument KSecAttrPassword'
  end

  describe '#password' do
    before do
      @item[KSecAttrProtocol] = KSecAttrProtocolHTTPS
      @item[KSecAttrServer]   = 'github.com'
    end
    it 'should return the stored password'
    it 'should return an empty string for blank passwords'
    it 'should not cache the password'
    it 'should raise an exception for an unexpected result code'
  end

  describe '#password=' do
    before do
      @item[KSecAttrProtocol] = KSecAttrProtocolHTTPS
      @item[KSecAttrServer]   = 'github.com'
    end
    it 'should return the stored password'
    it 'should update the password stored in the keychain'
    it 'sholud create entries if they do not exist'
    it 'should store a nil password as an empty string'
    it 'should not cache the password'
    it 'should raise an exception for an unexepected result code'
  end

  describe '#account' do
    'should be equivalent to #[KSecAttrAccount]' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :account
      item.account.should == item[KSecAttrAccount]
    end
  end

  describe '#account=' do
    'should be equivalent to #[KSecAttrAccount]=' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :account=
      item.account.should == item[KSecAttrAccount]
    end
  end

  describe '#server' do
    'should be equivalent to #[KSecAttrServer]' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :server
      item.server.should == item[KSecAttrServer]
    end
  end

  describe '#server=' do
    'should be equivalent to #[KSecAttrServer]=' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :server=
      item.server.should == item[KSecAttrServer]
    end
  end

  describe '#item_class' do
    'should be equivalent to #[KSecClass]' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :server
      item.server.should == item[KSecAttrServer]

    end
  end

  describe '#item_class=' do
    'should be equivalent to #[KSecClass]=' do
      item = Keychain.item( KSecAttrServer => 'github.com' )
      item.should respond_to :server
      item.server.should == item[KSecAttrServer]
    end
  end

  describe '#save!' do
    it 'should update a keychain item with @attributes if the item exists'
    # @todo will this work without setting a password at the same time?
    it 'should create a new keychain item if it does not exist'
    it 'should raise an exception for an unexpected result code'
    it 'should update @attributes'
    it 'should return self' do
      @item.save!.should be @item
    end
  end

  describe '#reload!' do
    it 'should return self' do
      @item.reload!.should be @item
    end
    it 'should update local @attributes with the keychain item'
    # @todo or should it just make @attributes an empty hash
    it 'should raise an exception if nothing is found'
    it 'should raise an exception for an unexpected error code'
  end

  describe '#exists?' do
    it 'should return true if the item exists' do
      @item[KSecAttrServer] = 'github.com'
      @item.exists?.should be_true
    end
    it 'should return false if the item does not exist' do
      @item[KSecAttrServer] = 'fake.example.org'
      @item.exists?.should be_false
    end
    it 'should return false if there is an unexpected result code' do
      @item[KSecClass] = 'ERROR'
      @item.exists?.should be_false
    end
  end

end
