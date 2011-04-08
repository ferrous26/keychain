require 'spec_helper'

describe Keychain::Item do

  before do @item = Keychain::Item.new end

  describe 'attributes' do
    it 'is readable' do
      @item.should respond_to :attributes
    end
    it 'is writable' do
      @item.should respond_to :attributes=
    end
    it 'is initialized with a default class' do
      @item.attributes[KSecClass].should == KSecClassInternetPassword
    end
    it 'allows the default class to be overridden' do
      ret = Keychain::Item.new(KSecClass => 'zomg made up')
      ret.attributes[KSecClass].should == 'zomg made up'
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
      @item[KSecAttrServer] = 'example.test.org'
    end
    it 'should return the stored password' do
      @item.password.should == 'password'
    end
    it 'should return an empty string for blank passwords' do
      @item[KSecAttrServer] = 'example2.test.org'
      @item.password.should be_empty
    end
    it 'should not cache the password' do
      cached_password = @item.password
      @item.attributes.values.should_not include cached_password
    end
    it 'should raise an exception for an unexpected result code' do
      @item[KSecClass] = 'madeup!'
      expect { @item.password }.to raise_error Keychain::KeychainException
    end
    it 'should not mutate the stored attributes' do
      before_attributes = @item.attributes.dup
      @item.password
      @item.attributes.should == before_attributes
    end
  end

  describe '#password=' do
    before do
      @item[KSecAttrServer] = 'example3.test.org'
      @password = Time.now.to_s
    end
    it 'should return the stored password' do
      @item.send(:password=, @password).should == @password
    end
    it 'should update the password stored in the keychain' do
      @item.password = @password
      @item.password.should == @password
    end
    ### PENDING
    it 'should create entries if they do not exist'
    ### PENDING
    it 'should store a nil password as an empty string' do
      @item.password = nil
      @item.password.should == ''
    end
    it 'should not cache the password' do
      @item.password = @password
      @item.attributes.values.should_not include @password
    end
    it 'should raise an exception for an unexepected result code' do
      @item[KSecClass] = ':)'
      expect {
        @item.password = @password
      }.to raise_error Keychain::KeychainException
    end
  end

  describe '#account' do
    it 'should be equivalent to #[KSecAttrAccount]' do
      @item[KSecAttrAccount] = 'test read name'
      @item.account.should == @item[KSecAttrAccount]
    end
  end

  describe '#account=' do
    it 'should be equivalent to #[KSecAttrAccount]=' do
      @item.account = 'test write name'
      @item[KSecAttrAccount].should == 'test write name'
    end
  end

  describe '#server' do
    it 'should be equivalent to #[KSecAttrServer]' do
      @item[KSecAttrServer] = 'github.com'
      @item.server.should == @item[KSecAttrServer]
    end
  end

  describe '#server=' do
    it 'should be equivalent to #[KSecAttrServer]=' do
      @item.server = 'example.org'
      @item[KSecAttrServer].should == 'example.org'
    end
  end

  describe '#item_class' do
    it 'should be equivalent to #[KSecClass]' do
      @item[KSecClass] = 'duh, winning'
      @item.item_class.should == @item[KSecClass]
    end
  end

  describe '#item_class=' do
    it 'should be equivalent to #[KSecClass]=' do
      @item.item_class = 'biwinning'
      @item[KSecClass].should == 'biwinning'
    end
  end

  describe '#save!' do
    before do @item[KSecAttrServer] = 'example9001.org' end
    it 'should return the saved attributes' do
      attrs = @item.attributes
      @item.save!.should be attrs
    end
    it 'should update a keychain item with @attributes if the item exists' do
      now = Time.now
      other_item = @item.dup
      @item[KSecAttrComment] = now
      @item.save!
      other_item.reload![KSecAttrComment].should == now
    end
    it 'should create a new keychain item if it does not exist'
    it 'should raise an exception for an unexpected result code' do
      @item[KSecClass] = 'asplode'
      expect { @item.save! }.to raise_error Keychain::KeychainException
    end
  end

  describe '#reload!' do
    before do @item[KSecAttrServer] = 'github.com' end
    it 'should return the reloaded attributes' do
      ret = @item.reload!
      ret.should be @item.attributes
    end
    it 'should update local @attributes with the keychain item' do
      @item[KSecAttrProtocol].should be_nil
      @item.reload!
      @item[KSecAttrProtocol].should == KSecAttrProtocolHTTPS
    end
    # @todo or should it just make @attributes an empty hash
    it 'should raise an exception if nothing is found' do
      @item[KSecAttrServer] = 'madeup.fake.domain'
      expect { @item.reload! }.to raise_error Keychain::KeychainException
    end
    it 'should raise an exception for an unexpected error code' do
      @item[KSecClass] = 'asplode'
      expect { @item.reload! }.to raise_error Keychain::KeychainException
    end
  end

  describe '#exists?' do
    it 'should return true if the item exists' do
      @item[KSecAttrServer] = 'github.com'
      @item.should exist
    end
    it 'should return false if the item does not exist' do
      @item[KSecAttrServer] = 'fake.example.org'
      @item.should_not exist
    end
    it 'should return false if there is an unexpected result code' do
      expect {
        @item[KSecClass] = 'ERROR'
        @item.exists?
      }.to raise_error Keychain::KeychainException
    end
  end

end
