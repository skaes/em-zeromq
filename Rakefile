require 'bundler'
require 'rspec/core/rake_task'

BUILDS = %w(ffi)

namespace :ffi do
  Bundler::GemHelper.install_tasks :name => 'em-zeromq'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--color']
    t.pattern = "spec/**/*_{spec,ffi}.rb"
  end
end

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "ruby"

  namespace :mri do
    Bundler::GemHelper.install_tasks :name => 'em-zeromq-mri'
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.rspec_opts = ['--color']
      t.pattern = "spec/**/*_{spec,mri}.rb"
    end
  end

  BUILDS << "mri"
end

[:spec, :build, :install, :release].each do |t|
  desc "#{t} all versions"
  task t => BUILDS.map{|b| "#{b}:#{t}" }
end

task :default => :spec

