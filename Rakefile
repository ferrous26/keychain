require 'rubygems'
require 'rake'

task :default => :spec
task :test    => :spec

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.skip_bundler = true
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new

desc 'AOT compile source files'
task :compile do
  FileList["lib/**/*.rb"].each do |source|
    name = File.basename source
    puts "#{name} => #{name}o"
    `macrubyc -C '#{source}' -o '#{source}o'`
  end
end

desc 'Clean *.rbo files'
task :clean do
  FileList["lib/**/*.rbo"].each do |bin|
    puts "Removing #{bin}"
    rm bin
  end
end

require 'rubygems'
require 'rubygems/builder'
require 'rubygems/installer'
spec = Gem::Specification.load('AXElements.gemspec')

desc 'Build the gem'
task :build do Gem::Builder.new(spec).build end

desc 'Build the gem and install it'
task :install => :build do Gem::Installer.new(spec.file_name).install end
end
