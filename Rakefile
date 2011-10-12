require 'bundler'
require 'rspec/core/rake_task'

namespace :ffi do
  Bundler::GemHelper.install_tasks :name => 'em-zeromq'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--color']
    t.pattern = "spec/**/*_{spec,ffi}.rb"
  end
end

namespace :c do
  Bundler::GemHelper.install_tasks :name => 'em-zeromq-c'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--color']
    t.pattern = "spec/**/*_{spec,c}.rb"
  end
end

[:spec, :build, :install, :release].each do |t|
  desc "#{t} all versions"
  task t => ["ffi:#{t}", "c:#{t}"]
end

task :default => :spec
