$LOAD_PATH.unshift File.join( File.dirname(__FILE__), 'lib' )
require 'mr_keychain/version'

Gem::Specification.new do |s|
  s.name    = 'mr_keychain'
  s.version = Keychain::VERSION

  s.summary     = 'A wrapper around the Mac OS X keychain for MacRuby'
  s.description = <<-EOS
Takes advantage of APIs new in Snow Leopard to create, read, and update keychain entries
using MacRuby.
  EOS
  s.authors       = ['Mark Rada']
  s.email         = 'marada@uwaterloo.ca'
  s.homepage      = 'http://github.com/ferrous26/keychain'
  s.licenses      = ['MIT']

  s.files            = [
                        'lib/mr_keychain.rb',
                        'lib/mr_keychain/item.rb',
                        'lib/mr_keychain/keychain.rb',
                        'lib/mr_keychain/keychain_exception.rb'
                       ]
  s.test_files       = [
                        'Rakefile',
                        'spec/spec_helper.rb',
                        'spec/item_spec.rb',
                        'spec/keychain_exception_spec.rb',
                        'spec/keychain_spec.rb'
                       ]
  s.extra_rdoc_files = [
                        '.yardopts',
                        'LICENSE.txt',
                        'README.markdown'
                       ]

  s.add_development_dependency 'rspec',       ['~> 2.6']
  s.add_development_dependency 'rspec-pride', ['~> 1.0']
  s.add_development_dependency 'yard',        ['~> 0.7.2']
  s.add_development_dependency 'redcarpet',   ['~> 1.17']
end
