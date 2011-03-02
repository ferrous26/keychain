Gem::Specification.new do |s|
  s.name    = 'mr_keychain'
  s.version = '0.1.1'

  s.required_rubygems_version = Gem::Requirement.new '>= 0'
  s.rubygems_version          = '1.4.2'

  s.summary     = 'Example code of how to use the Mac OS X keychain in MacRuby'
  s.description = <<-EOS
Takes advantage of MacRuby and uses APIs new in Snow Leopard to create, read, and update keychain entries
  EOS
  s.authors       = ['Mark Rada']
  s.email         = 'marada@uwaterloo.ca'
  s.homepage      = 'http://github.com/ferrous26/keychain'
  s.licenses      = ['MIT']
  s.has_rdoc      = 'yard'
  s.require_paths = ['lib']

  s.files            = [
                        'lib/mr_keychain.rb',
                        'lib/mr_keychain/item.rb',
                        'lib/mr_keychain/keychain.rb',
                        'lib/mr_keychain/keychain_exception.rb'
                       ]
  s.test_files       = [
                        '.rspec',
                        'spec/spec_helper.rb',
                        'spec/item_spec.rb',
                        'spec/keychain_exception_spec.rb',
                        'spec/keychain_spec.rb'
                       ]
  s.extra_rdoc_files = [
                        '.yardopts',
                        'Rakefile',
                        'LICENSE.txt',
                        'README.markdown'
                       ]

  s.add_development_dependency 'rake',      ['>= 0.8.7']
  s.add_development_dependency 'rspec',     ['~> 2.5.0']
  s.add_development_dependency 'yard',      ['~> 0.6.4']
  s.add_development_dependency 'bluecloth', ['~> 2.0.11']
end
