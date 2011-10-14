Gem::Specification.new do |s|
   s.name = "phenomenal"
   s.summary = "A context oriented programing framework for ruby"
   s.description = File.read(File.join(File.dirname(__FILE__),'README'))
   s.version = "0.6.2.7"
   s.authors = "Loic Vigneron - Thibault Poncelet"
   s.email = "thibault.poncelet@student.uclouvain.be - loic.vigneron@student.uclouvain.be"
   s.date = "2011-10-07"
   s.platform = Gem::Platform::RUBY
   s.required_ruby_version = '>=1.9.2'
   s.files = Dir['**/**']
   s.has_rdoc = false
   s.test_files = Dir['test/*.rb']
   s.homepage    = "http://www.phenomenal-gem.com"
end
