require 'rubygems'
require 'rake'

task :default => :spec
task :test    => :spec

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new

namespace :macruby do

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

end
