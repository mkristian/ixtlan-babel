task :default => [ :spec ]

task :spec do
  require 'rubygems'
  require 'bundler/setup'
  require 'minitest/autorun'
  Dir['spec/*_spec.rb'].each { |f| require f }
end
