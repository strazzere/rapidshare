require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

require 'lib/rapidshare/version'

spec = Gem::Specification.new do |s|
  s.name             = 'rapidshare'
  s.version          = Rapidshare::Version.to_s
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README.rdoc)
  s.rdoc_options     = %w(--main README.rdoc)
  s.summary          = "wrapper for Rapidshare API, enables file downloads from RS premium accounts"
  s.author           = 'Tomasz Mazur'
  s.email            = 'defkode@gmail.com'
  s.homepage         = 'http://trix.pl'
  s.files            = %w(README.rdoc Rakefile) + Dir.glob("{lib,test}/**/*")
  # s.executables    = ['rapidshare']
  
  s.add_dependency('httparty', '~> 0.4.5')
  s.add_dependency('progressbar', '~> 0.9.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new(:coverage) do |t|
    t.libs       = ['test']
    t.test_files = FileList["test/**/*_test.rb"]
    t.verbose    = true
    t.rcov_opts  = ['--text-report', "-x #{Gem.path}", '-x /Library/Ruby', '-x /usr/lib/ruby']
  end
  
  task :default => :coverage
  
rescue LoadError
  warn "\n**** Install rcov (sudo gem install relevance-rcov) to get coverage stats ****\n"
  task :default => :test
end

desc 'Generate the gemspec for the Gem (useful when serving from Github)'
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, 'w') {|f| f << spec.to_ruby }
  puts "Created gemspec: #{file}"
end

task :github => :gemspec
