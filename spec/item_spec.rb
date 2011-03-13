require 'spec_helper'

# @todo get the spec tests to use mock data
describe Keychain::Item do

  before do @item = Keychain::Item.new KSecClass => KSecClassInternetPassword end


  describe 'attributes attribute' do
    it 'is readable' do
      @item.respond_to?(:attributes).should == true
    end

    it 'is writable' do
      @item.respond_to?(:attributes=).should == true
    end
  end


  describe '#password' do
    it 'should return a string with the password' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.password.class.should == String
    end

    it 'should raise an exception if no password is found' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolIRCS,
                              KSecAttrServer   => 'github.com'
                              )
      expect { @item.password }.to raise_exception Keychain::KeychainException
    end

    it 'should return an empty string when the password is blank'
  end


  describe '#metadata' do
    it 'should return a hash' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.metadata.class.should == Hash
    end

    it 'should raise an exception if nothing is found' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolIRCS,
                              KSecAttrServer   => 'github.com'
                              )
      expect { @item.metadata }.to raise_exception(Keychain::KeychainException)
    end

    # this assumes the keychain item has more metadata
    it 'should not overwrite @attributes' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      metadata = @item.metadata
      @item.attributes.should_not == metadata
    end
  end


  describe '#metadata!' do
    it 'should return a hash' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.metadata.class.should == Hash
    end

    it 'should raise an exception if nothing is found' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolIRCS,
                              KSecAttrServer   => 'github.com'
                              )
      expect { @item.metadata }.to raise_exception(Keychain::KeychainException)
    end

    # this assumes the keychain item has more metadata
    it 'should overwrite @attributes' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      metadata = @item.metadata!
      @item.attributes.should == metadata
    end
  end


  describe '#[]' do
    it 'should be equivalent to #attributes' do
      @item.attributes[:test] = 'test'
      @item[:test].should == 'test'
      @item[KSecClass].should == @item.attributes[KSecClass]
    end
  end


  describe '#[]=' do
    it 'should be equivalent to #attributes=' do
      @item[:test] = 'test'
      @item.attributes[:test].should == 'test'
    end
  end


  # describe '#password=' do
  #   before do
  #     @item.attributes.merge!(
  #                             KSecAttrProtocol => KSecAttrProtocolHTTPS,
  #                             KSecAttrServer   => 'github.com'
  #                             )
  #   end

  #   it 'should return the updated password' do
  #     (@item.password = 'new password').should == 'new password'
  #   end

  #   it 'should update the password in the keychain' do
  #     (@item.password = 'new password').should == @item.password
  #   end

  #   it 'should create entries if they do not exsit' do
  #     @item.attributes.merge!(
  #                             KSecAttrAccount  => 'test'
  #                             )
  #     @item.password = 'another test'
  #     @item.exists?.should == true
  #   end

  #   after do
  #     NSLog('I created an entry in your keychain that you should clean up')
  #   end
  # end


  describe '#update!' do
    it 'should update fields given in the persistent keychain' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.update!( KSecAttrComment => 'test' )
      @item.metadata[KSecAttrComment].should == 'test'
    end

    it 'should raise an exception for non-existant items' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolIRCS,
                              KSecAttrServer   => 'github.com'
                              )
      expect {
        @item.update!( KSecAttrComment => 'different test' )
      }.to raise_exception(Keychain::KeychainException)
    end

    it 'should update @attributes' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.update!( KSecAttrComment => 'toast' )
      @item.attributes[KSecAttrComment].should == 'toast'
    end

    it 'should return the metadata of the keychain item' do
      @item.attributes.merge!(
                              KSecAttrProtocol => KSecAttrProtocolHTTPS,
                              KSecAttrServer   => 'github.com'
                              )
      @item.update!(
                    KSecAttrComment => 'bread'
                    )[KSecAttrComment].should == 'bread'
    end
  end

end
