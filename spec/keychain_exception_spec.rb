require 'spec_helper'

describe Keychain::Exception, '#initialize' do
  it 'should take a message prefix and an error code' do
    Keychain::KeychainException.instance_method(:initialize).arity.should be 2
    expect { Keychain::KeychainException.new '', ErrSecSuccess }.to_not raise_error ArgumentError
    expect { Keychain::KeychainException.new '', ErrSecSuccess }.to_not raise_error TypeError
  end
  it 'should add the prefix to beginning of the error message' do
    exception = Keychain::KeychainException.new 'my prefix', 0
    exception.message.should match /^my prefix/
  end
  it 'should look up the error code for the error message' do
    exception = Keychain::KeychainException.new 'test', ErrSecUnimplemented
    exception.message.should match /not implemented/
  end
end
