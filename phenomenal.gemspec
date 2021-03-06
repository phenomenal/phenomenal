$:.push File.expand_path("../lib", __FILE__)
# Maintain your gem's version:
require "phenomenal/version"

Gem::Specification.new do |s|
   s.name = "phenomenal"
   s.summary = "A context oriented programming framework for Ruby"
   s.description = "A context oriented programming framework for Ruby"
   s.version = Phenomenal::VERSION
   s.authors = "Loic Vigneron - Thibault Poncelet"
   s.email = "team@phenomenal-gem.com"
   s.platform = Gem::Platform::RUBY
   s.required_ruby_version = '>=1.9.2'
   s.files = Dir["{lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
   s.has_rdoc = true
   s.test_files  = Dir.glob("spec/**/*.rb")
   s.homepage    = "http://www.phenomenal-gem.com"
   s.add_development_dependency 'rspec', '~> 2.5'
end
