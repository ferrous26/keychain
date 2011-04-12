require 'spec_helper'

describe Keychain::Item do

  def sneak_peak_attrs item
    item.instance_variable_get(:@attributes) # HACK!
  end

  before do @item = Keychain::Item.new end

  describe '#initialize' do
    it 'is initialized with a default class' do
      @item[KSecClass].should == KSecClassInternetPassword
    end
    it 'allows the default class to be overridden' do
      klass = 'zomg made up'
      ret = Keychain::Item.new(KSecClass => klass)
      ret[KSecClass].should be klass
    end
  end

  describe '#[]' do
    it 'allows reading of keychain attributes' do
      @item[KSecClass].should == KSecClassInternetPassword
    end
    it 'should add a special case for argument KSecAttrPassword' do
      @item[KSecAttrServer] = 'example.test.org'
      @item[KSecAttrPassword].should == @item.password
    end
  end

  describe '#attributes' do
    it 'should include all the attributes' do
      @item['test'] = 'test'
      @item[KSecAttrServer] = 'example.org'
      @item[:madeupkey] = 'madeupvalue'

      @item.attributes.keys.should include 'test'
      @item.attributes.keys.should include KSecAttrServer
      @item.attributes.keys.should include :madeupkey
    end
    it 'should be a duplicate of the attributes' do
      @item.attributes.should_not be @item.instance_variable_get(:@attributes)
    end
  end

  describe '#[]=' do
    it 'allows writing of attributes' do
      site = 'a.website.com'
      @item[KSecAttrServer] = site
      @item[KSecAttrServer].should be site
    end
    it 'should only save changes locally' do
      comment = 'roflcopter'
      @item[KSecAttrServer] = 'github.com'
      @item.reload!
      @item[KSecAttrComment] = comment
      new_item = Keychain.item( KSecAttrServer => 'github.com' )
      new_item[KSecAttrComment].should_not == comment
    end
    it 'should add a special case for argument KSecAttrPassword' do
      def @item.password= value
        :got_called
      end
      (@item.send(:[]=,KSecAttrPassword,'test')).should == :got_called
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

  describe '#password' do
    before do @item[KSecAttrServer] = 'example.test.org' end
    it 'should return the stored password' do
      @item.password.should == 'password'
    end
    it 'should return an empty string for blank passwords' do
      @item[KSecAttrServer] = 'example2.test.org'
      @item.password.should be_empty
    end
    it 'should not cache the password' do
      cached_password = @item.password
      sneak_peak_attrs(@item).values.should_not include cached_password
    end
    it 'should raise an exception for an unexpected result code' do
      @item[KSecClass] = 'madeup!'
      expect { @item.password }.to raise_error Keychain::KeychainException
    end
    it 'should not mutate the stored attributes' do
      before_attributes = sneak_peak_attrs(@item).dup
      @item.password
      sneak_peak_attrs(@item).should == before_attributes
    end
    it 'should still find the original item if unsaved changes have been made'
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
    it 'should store a nil password as an empty string' do
      @item.password = nil
      @item.password.should == ''
    end
    it 'should not cache the password' do
      @item.password = @password
      sneak_peak_attrs(@item).values.should_not include @password
    end
    it 'should raise an exception for an unexepected result code' do
      @item[KSecClass] = ':)'
      expect {
        @item.password = @password
      }.to raise_error Keychain::KeychainException
    end
    it 'should create entries if they do not exist'
    it 'should still find the original item if unsaved changes have been made'
  end

  describe '#method_missing' do
    it 'should do attribute lookups for simple attributes' do
      @item[KSecAttrAccount] = 'test read name'
      @item.account.should == @item[KSecAttrAccount]
    end
    it 'should do attribute lookups for complex attributes' do
      @item[KSecAttrModificationDate] = 'test write name'
      @item.modification_date.should == @item[KSecAttrModificationDate]
    end
    it 'should do attribute lookups for predicate attributes' do
      @item[KSecAttrIsInvisible] = true
      @item.should be_invisible
    end
    it 'should do attribute setting for simple attributes' do
      @item.server = 'example.org'
      @item[KSecAttrServer].should == 'example.org'
    end
    it 'should do attribute setting for complex attributes' do
      @item.authentication_type = KSecAttrAuthenticationTypeNTLM
      @item[KSecAttrAuthenticationType].should == KSecAttrAuthenticationTypeNTLM
    end
    it 'should do attribute setting for really complex attributes' do
      @item.invisible = true
      @item[KSecAttrIsInvisible].should be_true
    end
    it 'should delegate up if the attribute is not found' do
      expect {
        @item.totally_fake_method_name
      }.to raise_error NoMethodError
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
    it 'should still find the original item if unsaved changes have been made'
  end

  describe '#reload!' do
    before do @item[KSecAttrServer] = 'github.com' end
    it 'should return the reloaded attributes' do
      ret = @item.reload!
      ret.should be sneak_peak_attrs(@item)
    end
    it 'should update local @attributes with the keychain item' do
      @item[KSecAttrProtocol].should be_nil
      @item.reload!
      @item[KSecAttrProtocol].should == KSecAttrProtocolHTTPS
    end
    it 'should raise an exception if nothing is found' do
      @item[KSecAttrServer] = 'madeup.fake.domain'
      expect { @item.reload! }.to raise_error Keychain::KeychainException
    end
    it 'should raise an exception for an unexpected error code' do
      @item[KSecClass] = 'asplode'
      expect { @item.reload! }.to raise_error Keychain::KeychainException
    end
    it 'should still find the original item if unsaved changes have been made'
    it 'should overwrite local changes to existing attributes'
    it 'should not overwrite local changes to new attributes'
  end

  # describe '#save!' do
  #   before do @item[KSecAttrServer] = 'example9001.org' end
  #   it 'should return the saved attributes' do
  #     attrs = sneak_peak_attrs(@item)
  #     @item.save!.should be attrs
  #   end
  #   it 'should update a keychain item with @attributes if the item exists' do
  #     now = Time.now
  #     other_item = @item.dup
  #     @item[KSecAttrComment] = now
  #     @item.save!
  #     other_item.reload![KSecAttrComment].should == now
  #   end
  #   it 'should create a new keychain item if it does not exist'
  #   it 'should raise an exception for an unexpected result code' do
  #     @item[KSecClass] = 'asplode'
  #     expect { @item.save! }.to raise_error Keychain::KeychainException
  #   end
  #   it 'should not overwrite the existing password'
  # end

  describe '#unsaved' do
    it 'returns a hash of all unsaved attribute changes' do
      @item[KSecAttrServer] = 'madeup.domain.com'
      @item.comment         = '1337 h4x'
      @item.unsaved.keys.should include KSecAttrServer
      @item.unsaved.keys.should include KSecAttrComment
    end
    it 'returns an empty hash right after item initialization' do
      @item.unsaved.should be_empty
    end
    it 'return an empty hash right after saving' do
    end
  end

end
