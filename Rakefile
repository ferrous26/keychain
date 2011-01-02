require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "keychain"
  gem.homepage = "http://github.com/ferrous26/keychain"
  gem.license = "MIT"
  gem.summary = %Q{Example code of how to use the Mac OS X keychain in MacRuby}
  gem.description = %Q{Uses APIs new in Snow Leopard to create, read, and update keychain entries}
  gem.email = "marada@uwaterloo.ca"
  gem.authors = ["Mark Rada"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
