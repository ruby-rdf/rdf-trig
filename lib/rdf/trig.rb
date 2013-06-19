require 'rdf'
require 'ebnf'

module RDF
  ##
  # **`RDF::TriG`** is an TriG plugin for RDF.rb.
  #
  # @example Requiring the `RDF::TriG` module
  #   require 'rdf/trig'
  #
  # @example Parsing RDF statements from an TriG file
  #   RDF::TriG::Reader.open("etc/foaf.trig") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @see http://rubydoc.info/github/ruby-rdf/rdf-turtle/
  # @see http://rubydoc.info/github/ruby-rdf/rdf/master/
  # @see http://dvcs.w3.org/hg/rdf/raw-file/default/trig/index.html
  #
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module TriG
    require  'rdf/trig/format'
    autoload :Reader,     'rdf/trig/reader'
    autoload :VERSION,    'rdf/trig/version'
    autoload :Writer,     'rdf/trig/writer'

    def self.debug?; @debug; end
    def self.debug=(value); RDF::Turtle.debug = @debug = value; end
  end
end
