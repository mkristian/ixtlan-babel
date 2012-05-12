task :default => [ :spec ]

task :spec do
  require 'rubygems'
  require 'bundler/setup'
  require 'minitest/autorun'

  $LOAD_PATH << "spec"

  Dir['spec/*_spec.rb'].each { |f| require File.basename(f.sub(/.rb$/, '')) }
end
