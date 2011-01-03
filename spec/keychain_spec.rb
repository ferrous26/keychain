require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# @todo get the spec tests to use mock data
describe 'Keychain' do

  describe 'Item' do

    before do
      @item = Keychain::Item.new
    end


    describe 'attributes attribute' do
      it 'is readable' do
        @item.respond_to?(:attributes).should == true
      end

      it 'is writable' do
        @item.respond_to?(:attributes=).should == true
      end

      it 'should be initialized with the class being set' do
        @item.attributes[KSecClass].should_not == nil
      end

      it 'should be initialized to be of the interenet class' do
        @item.attributes[KSecClass].should == KSecClassInternetPassword
      end

      it 'should allow the class to be overriden' do
        @item = Keychain::Item.new({ KSecClass => 'different' })
        @item.attributes[KSecClass].should == 'different'
      end
    end


    describe '#exists?' do
      it 'returns false if the item does not exist' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolIRCS,
          KSecAttrServer   => 'github.com'
        })
        @item.exists?.should == false
      end

      it 'returns true if the item exists' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        @item.exists?.should == true
      end

      it 'raises an exception for unexpected error codes' do
        @item.attributes[KSecClass] = 'made up class'
        expect { @item.exists? }.to raise_exception(Keychain::KeychainException)
      end
    end


    describe '#password' do
      it 'should return a string with the password' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        @item.password.class.should == String
      end

      it 'should raise an exception if no password is found' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolIRCS,
          KSecAttrServer   => 'github.com'
        })
        expect { @item.password }.to raise_exception(Keychain::KeychainException)
      end
    end


    describe '#metadata' do
      it 'should return a hash' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        @item.metadata.class.should == Hash
      end

      it 'should raise an exception if nothing is found' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolIRCS,
          KSecAttrServer   => 'github.com'
        })
        expect { @item.metadata }.to raise_exception(Keychain::KeychainException)
      end

      # this assumes the keychain item has more metadata
      it 'should not overwrite @attributes' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        metadata = @item.metadata
        @item.attributes.should_not == metadata
      end
    end


    describe '#metadata!' do
      it 'should return a hash' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        @item.metadata.class.should == Hash
      end

      it 'should raise an exception if nothing is found' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolIRCS,
          KSecAttrServer   => 'github.com'
        })
        expect { @item.metadata }.to raise_exception(Keychain::KeychainException)
      end

      # this assumes the keychain item has more metadata
      it 'should overwrite @attributes' do
        @item.attributes.merge!({
          KSecAttrProtocol => KSecAttrProtocolHTTPS,
          KSecAttrServer   => 'github.com'
        })
        metadata = @item.metadata!
        @item.attributes.should == metadata
      end
    end

  end

end
