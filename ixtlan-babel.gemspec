# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-babel'
  s.version = '0.7.0'

  s.summary = 'filter for hashes and serialization of POROs into a hash representation'
  s.description = 'filter for hashes and serialization of POROs into a hash representation. both the filter and hash reprensentation use a similar DSL to define which attributes are used/allowed'
  s.homepage = 'http://github.com/mkristian/ixtlan-babel'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT'
#   s.files += Dir['History.txt']
  s.files += Dir['README.md']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['*file']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_development_dependency 'rake', '~>10.3'
  s.add_development_dependency 'minitest', '~>5.3'
  s.add_development_dependency 'multi_json', '~>1.10'
  s.add_development_dependency 'virtus', '~>1.0'
end

# vim: syntax=Ruby
