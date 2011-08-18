require 'rake/testtask'
include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList['test/unit/*_test.rb']
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r rapidshare.rb"
end
