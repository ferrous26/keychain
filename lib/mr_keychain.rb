framework 'Foundation'

##
# Classes, modules, methods, and constants relevant to working with the
# Mac OS X keychain.
module Keychain
end

unless Kernel.const_defined?(:KSecAttrPassword)
  # This is a special constant that allows {Keychain::Item} to treat a
  # password as if it were like the other keychain item attributes.
  # @return [String]
  KSecAttrPassword = 'pass'
end

require 'mr_keychain/core_ext'
require 'mr_keychain/version'
require 'mr_keychain/keychain'
require 'mr_keychain/item'
require 'mr_keychain/keychain_exception'
