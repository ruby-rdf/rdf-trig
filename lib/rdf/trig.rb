require 'rdf'

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
  # @see http://rubydoc.info/github/gkellogg/rdf-turtle/master/frames
  # @see http://rubydoc.info/github/gkellogg/rdf/master/frames
  # @see http://dvcs.w3.org/hg/rdf/raw-file/default/trig/index.html
  #
  # @author [Gregg Kellogg](http://kellogg-assoc.com/)
  module TriG
    require  'rdf/trig/format'
    autoload :Reader,     'rdf/trig/reader'
    autoload :VERSION,    'rdf/trig/version'
    autoload :Writer,     'rdf/trig/writer'

    KEYWORDS  = %w(@base @prefix).map(&:to_sym)
    
    def self.debug?; @debug; end
    def self.debug=(value); RDF::Turtle.debug = @debug = value; end
  end
end
