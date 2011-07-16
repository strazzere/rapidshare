require 'rake/testtask'
include Rake::DSL

require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList['test/unit/*_test.rb']
end
