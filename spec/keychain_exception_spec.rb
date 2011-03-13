require 'spec_helper'

describe Keychain::Exception do

  describe '#initialize' do
    it 'should take an error code as a Fixnum' do
      expect { Keychain::KeychainException.new 'test', 0 }.to_not raise_error ArgumentError
      expect { Keychain::KeychainException.new 'test', 0 }.to_not raise_error TypeError
    end

    it 'should take a result code constant' do
      expect { Keychain::KeychainException.new 'test', ErrSecSuccess }.to_not raise_error ArgumentError
      expect { Keychain::KeychainException.new 'test', ErrSecSuccess }.to_not raise_error TypeError
    end

    it 'should look up the error code for the error message' do
      exception = Keychain::KeychainException.new 'test', ErrSecUnimplemented
      exception.message.should match /not implemented/
    end

    it 'should take a message prefix' do
      exception = Keychain::KeychainException.new 'my prefix', 0
      exception.message.should match /^my prefix/
    end
  end

end
