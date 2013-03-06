require 'rdf/turtle'
require 'rdf/trig/meta'

module RDF::TriG
  ##
  # A parser for the TriG
  #
  # Leverages the Turtle reader
  class Reader < RDF::Turtle::Reader
    format Format
    include RDF::TriG::Meta

    # String terminals
    terminal(nil,                  %r([\{\}\(\),.;\[\]a]|\^\^|@base|@prefix|true|false)) do |prod, token, input|
      case token.value
      when 'a'                then input[:resource] = RDF.type
      when 'true', 'false'    then input[:resource] = RDF::Literal::Boolean.new(token.value)
      when '@base', '@prefix' then input[:lang] = token.value[1..-1]
      else                         input[:string] = token.value
      end
    end

    # Productions
    # [3g] graph defines the basic creation of context
    start_production(:graph) do |input, current, callback|
      callback.call(:context, "graph", nil)
    end
    production(:graph) do |input, current, callback|
      callback.call(:context, "graph", nil)
    end
    
    # [4g] graphIri
    # Normally, just returns the IRIref, but if called from [3g], also
    # sets the context for triples defined within that graph
    production(:graphIri) do |input, current, callback|
      # If input contains set_graph_iri, use the returned value to set @context
      debug("graphIri") {"Set graph context to #{current[:resource]}"}
      callback.call(:context, "graphIri", current[:resource])
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
        when :context
          @context = data[0]
        when :statement
          data << @context if @context
          debug("each_statement") {"data: #{data.inspect}, context: #{@context.inspect}"}
          add_statement(loc, RDF::Statement.from(data))
        when :trace
          debug(loc, *data)
        end
      end
    rescue EBNF::LL1::Parser::Error => e
      debug("Parsing completed with errors:\n\t#{e.message}")
      raise RDF::ReaderError, e.message if validate?
    end
    
    ##
    # Iterates the given block for each RDF quad in the input.
    #
    # @yield  [subject, predicate, object, context]
    # @yieldparam [RDF::Resource] subject
    # @yieldparam [RDF::URI]      predicate
    # @yieldparam [RDF::Value]    object
    # @yieldparam [RDF::URI]      context
    # @return [void]
    def each_quad(&block)
      each_statement do |statement|
        block.call(*statement.to_quad)
      end
    end
  end # class Reader
end # module RDF::Turtle
