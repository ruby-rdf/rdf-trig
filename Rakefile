#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'

namespace :gem do
  desc "Build the rdf-trig-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build rdf-trig.gemspec && mv rdf-trig-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the rdf-trig-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/rdf-trig-#{File.read('VERSION').chomp}.gem"
  end
end
