$:.unshift(File.expand_path("../../lib", __FILE__))
$:.unshift File.dirname(__FILE__)

require "bundler/setup"
require 'rspec'
require 'matchers'
require 'rdf/trig'
require 'rdf/nquads'
require 'rdf/spec'
require 'rdf/spec/matchers'
require 'rdf/isomorphic'

# Create and maintain a cache of downloaded URIs
URI_CACHE = File.expand_path(File.join(File.dirname(__FILE__), "uri-cache"))
Dir.mkdir(URI_CACHE) unless File.directory?(URI_CACHE)

module RDF
  module Isomorphic
    alias_method :==, :isomorphic_with?
  end
end

::RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
  c.exclusion_filter = {
    :ruby => lambda { |version| !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) },
  }
  c.include(RDF::Spec::Matchers)
end
