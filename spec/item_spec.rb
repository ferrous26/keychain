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
    it 'should update the password stored in the keychain'
    it 'should return the stored password'
    it 'should return an empty string for blank passwords'
    it 'should not cache the password'
    it 'should raise an exception for an unexpected result code'
  end

  describe '#password=' do
    it 'should return the stored password'
    it 'sholud create entries if they do not exist'
    it 'should store a nil password as an empty string'
    it 'should not cache the password'
    it 'should raise an exception for an unexepected result code'
  end

  describe '#account' do
    'should be equivalent to #[KSecAttrAccount]'
  end

  describe '#account=' do
    'should be equivalent to #[KSecAttrAccount]='
  end

  describe '#server' do
    'should be equivalent to #[KSecAttrServer]'
  end

  describe '#server=' do
    'should be equivalent to #[KSecAttrServer]='
  end

  describe '#item_class' do
    'should be equivalent to #[KSecClass]'
  end

  describe '#item_class=' do
    'should be equivalent to #[KSecClass]='
  end

  describe '#save!' do
    it 'should update a keychain item with @attributes if the item exists'
    # @todo will this work without setting a password at the same time?
    it 'should create a new keychain item if it does not exist'
    it 'should raise an exception for an unexpected result code'
    it 'should update @attributes'
    it 'should return self'
  end

  #  don't overwrite attributes with extra search parameters
  #  password should not be cached
  #  raise appropriate errors in error cases
  describe '#reload!' do
    it 'should return self'
    it 'should update local @attributes with the keychain item'
    # @todo or should it just make @attributes an empty hash
    it 'should raise an exception if nothing is found'
    it 'should raise an exception for an unexpected error code'
  end

  describe '#exists?' do
    it 'should return true if the item exists'
    it 'should return false if the item does not exist'
    it 'should return false if there is an unexpected result code'
  end

end
