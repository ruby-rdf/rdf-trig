require 'rdf/trig/meta'
require 'rdf/turtle'

module RDF::TriG
  ##
  # A parser for the TriG
  #
  # Leverages the Turtle reader
  class Reader < RDF::Turtle::Reader
    format Format
    include RDF::TriG::Meta

    # String terminals
    terminal(nil,                  %r([\{\}\(\),.;\[\]a]|\^\^|@base|@prefix|true|false)) do |reader, prod, token, input|
      case token.value
      when 'a'             then input[:resource] = RDF.type
      when 'true', 'false' then input[:resource] = RDF::Literal::Boolean.new(token.value)
      else                      input[:string] = token.value
      end
    end
    terminal(:LANGTAG,              LANGTAG) do |reader, prod, token, input|
      input[:lang] = token.value[1..-1]
    end

    # Productions
    # [3g] graph defines the basic creation of context
    production(:graph) do |reader, phase, input, current, callback|
      current[:context] = nil
    end
    
    # [4g] graphIri
    # Normally, just returns the IRIref, but if called from [3g], also
    # sets the context for triples defined within that graph
    production(:graphIri) do |reader, phase, input, current, callback|
      # If input contains set_graph_iri, use the returned value to set @context
      if phase == :finish
        callback.call(:trace, "graphIri", lambda {"Set graph context to #{current[:resource]}"})
        input[:context] = current[:resource]
      end
    end
    
    # [12] object ::= IRIref | blank | literal
    production(:object) do |reader, phase, input, current, callback|
      next unless phase == :finish
      if input[:object_list]
        # Part of an rdf:List collection
        input[:object_list] << current[:resource]
      else
        callback.call(:trace, "object", lambda {"current: #{current.inspect}"})
        callback.call(:statement, "object", input[:subject], input[:predicate], current[:resource], input[:context])
      end
    end

    # [16] collection ::= "(" object* ")"
    production(:collection) do |reader, phase, input, current, callback|
      if phase == :start
        current[:object_list] = []  # Tells the object production to collect and not generate statements
      else
        # Create an RDF list
        bnode = reader.bnode
        objects = current[:object_list]
        list = RDF::List.new(bnode, nil, objects)
        list.each_statement do |statement|
          # Spec Confusion, referenced section "Collection" is missing from the spec.
          # Anicdodal evidence indicates that some expect each node to be of type rdf:list,
          # but existing Notation3 and Turtle tests (http://www.w3.org/2001/sw/DataAccess/df1/tests/manifest.ttl) do not.
          next if statement.predicate == RDF.type && statement.object == RDF.List
          callback.call(:statement, "collection", statement.subject, statement.predicate, statement.object, input[:context])
        end
        bnode = RDF.nil if list.empty?

        # Return bnode as resource
        input[:resource] = bnode
      end
    end

    ##
    # Iterates the given block for each RDF statement in the input.
    #
    # @yield  [statement]
    # @yieldparam [RDF::Statement] statement
    # @return [void]
    def each_statement(&block)
      @callback = block

      parse(@input, START.to_sym, @options.merge(:branch => BRANCH,
                                                 :first => FIRST,
                                                 :follow => FOLLOW)
      ) do |context, *data|
        loc = data.shift
        case context
        when :statement
          add_statement(loc, RDF::Statement.from(data))
        when :trace
          debug(loc, *data)
        end
      end
    rescue RDF::LL1::Parser::Error => e
      debug("Parsing completed with errors:\n\t#{e.message}")
      raise RDF::ReaderError, e.message if validate?
    end
    
    ##
    # Iterates the given block for each RDF quad in the input.
    #
    # @yield  [subject, predicate, object]
    # @yieldparam [RDF::Resource] subject
    # @yieldparam [RDF::URI]      predicate
    # @yieldparam [RDF::Value]    object
    # @return [void]
    def each_quad(&block)
      each_statement do |statement|
        block.call(*statement.to_quad)
      end
    end
  end # class Reader
end # module RDF::Turtle
