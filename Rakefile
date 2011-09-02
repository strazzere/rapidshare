require 'rake/testtask'
include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << %w{ lib test }
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rapidshare.rb"
end
