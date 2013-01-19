# -*- coding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-babel'
  s.version = '0.3.0'

  s.summary = 'babel offers a filter for hashes and with that comes json/yaml/xml de/serialization of models which provides a hash representation'
  s.description = 'babel offers a filter for hashes and with that comes json/yaml/xml de/serialization of models which provides a hash representationi. possible models are activerecord, activemodel, resources from datamapper, virtus'
  s.homepage = 'https://github.com/mkristian/ixtlan-babel'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.license = 'MIT'

  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['MIT-LICENSE'] + Dir['*.md']
  s.files += Dir['Gemfile']

  s.test_files += Dir['spec/**/*_spec.rb']

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'copyright-header', '~> 1.0.7'
  s.add_development_dependency 'minitest', '~> 4.3.0'
  s.add_development_dependency 'virtus', '~> 0.5.0'
end
