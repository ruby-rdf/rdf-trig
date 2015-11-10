$:.unshift(File.expand_path("../../lib", __FILE__))
$:.unshift File.dirname(__FILE__)

require "bundler/setup"
require 'rspec'
require 'matchers'
require 'rdf'
require 'rdf/nquads'
require 'rdf/spec'
require 'rdf/spec/matchers'
require 'rdf/isomorphic'
begin
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end
require 'rdf/trig'

module RDF
  module Isomorphic
    alias_method :==, :isomorphic_with?
  end
end

::RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.exclusion_filter = {
    ruby: lambda { |version| !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) },
  }
  c.include(RDF::Spec::Matchers)
end
