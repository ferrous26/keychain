require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
  end
end
