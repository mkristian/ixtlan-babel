# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'babel'
  s.version = '0.1'

  s.summary = 'babel offers a filter for hashes and with that comes json/yaml/xml de/serialization of models which provides a hash representation'

  s.authors = ['Kristian Meier']
  s.email = ['m.kristian@web.de']


  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  #s.add_development_dependency 'virtus', '~>0.9.0'
  s.add_development_dependency 'minitest', '2.11.3'
end
