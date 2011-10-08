# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rapidshare/version"

Gem::Specification.new do |s|
  s.name        = "rapidshare"
  s.version     = Rapidshare::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tomasz Mazur", "Lukas Stejskal"]
  s.email       = ["defkode@gmail.com", "lucastej@gmail.com"]
  s.homepage    = "http://github.com/defkode/rapidshare"
  s.summary     = %q{Rapidshare API}
  # s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "rapidshare"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rake', '~> 0.9.2')
  s.add_dependency('yard', '~> 0.7')
  # TODO replace with Net::HTTPS or Curb
  s.add_dependency('httparty', '~> 0.6')
  s.add_dependency('curb', '~> 0.7')
  s.add_dependency('progressbar', '~> 0.9')

  # test dependencies 
  s.add_development_dependency('shoulda')
  s.add_development_dependency('turn')
  s.add_development_dependency('fakeweb')
end
