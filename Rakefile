require 'rubygems'

task :default => :spec
task :test    => :spec

def safe_require path, name
  require path
  yield
rescue LoadError => e
  $stderr.puts "It seems as though you do not have #{name} installed."
  command = ENV['RUBY_VERSION'] ? 'gem' : 'sudo macgem'
  $stderr.puts "You can install it by running `#{command} install #{name}`."
end

if MACRUBY_REVISION.match /^git commit/
  require 'rake/compiletask'
  Rake::CompileTask.new do |t|
    t.files = FileList["lib/**/*.rb"]
    t.verbose = true
  end
end

require 'rake/gempackagetask'
require 'rubygems/installer'

spec = Gem::Specification.load('mr_keychain.gemspec')

Rake::GemPackageTask.new(spec) { }

# This only installs this gem, it does not take deps into consideration
desc 'Build gem and install it'
task :install => :gem do
  Gem::Installer.new("pkg/#{spec.file_name}").install
end

safe_require 'rspec/core/rake_task', 'rspec' do
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.skip_bundler = true
    spec.ruby_opts    = ['-rspec/spec_helper']
  end
end

safe_require 'yard', 'yard' do
  YARD::Rake::YardocTask.new
end
