# RDF::TriG reader/writer
[TriG][] reader/writer for [RDF.rb][RDF.rb] .

## Description
This is a [Ruby][] implementation of a [TriG][] reader and writer for [RDF.rb][].

## Features
RDF::TriG parses [TriG][Turtle] into statements or quads. It also serializes to TriG.

Install with `gem install rdf-trig`

* 100% free and unencumbered [public domain](http://unlicense.org/) software.
* Implements a complete parser for [TriG][].
* Compatible with Ruby 1.8.7+, Ruby 1.9.x, and JRuby 1.4/1.5.

## Usage
Instantiate a reader from a local file:

    repo = RDF::Repository.load("etc/doap.trig", :format => :trig)

Define `@base` and `@prefix` definitions, and use for serialization using `:base_uri` an `:prefixes` options.

Canonicalize and validate using `:canonicalize` and `:validate` options.

Write a graph to a file:

    RDF::TriG::Writer.open("etc/test.trig") do |writer|
       writer << repo
    end

## Documentation
Full documentation available on [Rubydoc.info][TriG doc].

### Principle Classes
* {RDF::TriG::Format}
* {RDF::TriG::Reader}
* {RDF::TriG::Writer}

### Variations from the spec
In some cases, the specification is unclear on certain issues:

* In section 2.1, the [spec][TriG] indicates that "Literals ,
  prefixed names and IRIs may also contain escapes to encode surrounding syntax ...",
  however the description in 5.2 indicates that only IRI\_REF and the various STRING\_LITERAL terms
  are subject to unescaping. This means that an IRI which might otherwise be representable using a PNAME
  cannot if the IRI contains any characters that might need escaping. This implementation currently abides
  by this restriction. Presumably, this would affect both PNAME\_NS and PNAME\_LN terminals.
  (This is being tracked as issues [67](http://www.w3.org/2011/rdf-wg/track/issues/67)).
* The EBNF definition of IRI_REF seems malformed, and has no provision for \^, as discussed elsewhere in the spec.
  We presume that [#0000- ] is intended to be [#0000-#0020].
* The list example in section 6 uses a list on it's own, without a predicate or object, which is not allowed
  by the grammar (neither is a blankNodeProperyList). Either the EBNF should be updated to allow for these
  forms, or the examples should be changed such that ( ... ) and [ ... ] are used only in the context of being
  a subject or object. This implementation will generate triples, however an error will be generated if the
  parser is run in validation mode.
* For the time being, plain literals are generated without an xsd:string datatype, but literals with an xsd:string
  datatype are saved as non-datatyped triples in the graph. This will be updated in the future when the rest of the
  library suite is brought up to date.

## Implementation Notes
The reader uses the Turtle parser, which is based on the LL1::Parser with minor updates for the TriG grammar. The writer also is based on the Turtle writer.
      
## Dependencies

* [Ruby](http://ruby-lang.org/) (>= 1.8.7) or (>= 1.8.1 with [Backports][])
* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.4)
* [rdf-turtle](http://rubygems.org/gems/rdf-turtle) (>= 0.1.1)

## Installation

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `RDF::TriG` gem, do:

    % [sudo] gem install rdf-trig

## Mailing List
* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Author
* [Gregg Kellogg](http://github.com/gkellogg) - <http://kellogg-assoc.com/>

## Contributing
* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you.

## License
This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:         http://ruby-lang.org/
[RDF]:          http://www.w3.org/RDF/
[YARD]:         http://yardoc.org/
[YARD-GS]:      http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:          http://lists.w3.org/Archives/Public/public-rdf-ruby/2010May/0013.html
[RDF.rb]:       http://rdf.rubyforge.org/
[Backports]:    http://rubygems.org/gems/backports
[TriG]:         http://dvcs.w3.org/hg/rdf/raw-file/default/trig/
[TriG doc]:     http://rubydoc.info/github/gkellogg/rdf-trig/master/file/README.markdown
[TriG EBNF]:    http://dvcs.w3.org/hg/rdf/raw-file/default/trig/trig.bnf