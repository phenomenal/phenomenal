$:.push File.expand_path("../lib", __FILE__)
# Maintain your gem's version:
require "phenomenal/version"

Gem::Specification.new do |s|
   s.name = "phenomenal"
   s.summary = "A context oriented programming framework for ruby"
   s.description = "A context oriented programming framework for ruby"
   s.version = Phenomenal::VERSION
   s.authors = "Loic Vigneron - Thibault Poncelet"
   s.email = "thibault.poncelet@student.uclouvain.be - loic.vigneron@student.uclouvain.be"
   s.date = "2011-11-24"
   s.platform = Gem::Platform::RUBY
   s.required_ruby_version = '>=1.9.2'
   s.files = Dir["{lib}/**/*"] + ["LICENSE", "Rakefile", "README"]
   s.has_rdoc = true
   s.test_files  = Dir.glob("{spec,test}/**/*.rb")
   s.homepage    = "http://www.phenomenal-gem.com"
   s.add_development_dependency 'rspec', '~> 2.5'
end
