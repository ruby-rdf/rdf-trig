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

    # Terminals passed to lexer. Order matters!
    terminal(:ANON,                 ANON) do |prod, token, input|
      input[:resource] = self.bnode
    end
    terminal(:BLANK_NODE_LABEL,     BLANK_NODE_LABEL) do |prod, token, input|
      input[:resource] = self.bnode(token.value[2..-1])
    end
    terminal(:IRIREF,               IRIREF, :unescape => true) do |prod, token, input|
      input[:resource] = process_iri(token.value[1..-2])
    end
    terminal(:DOUBLE,               DOUBLE) do |prod, token, input|
      # Note that a Turtle Double may begin with a '.[eE]', so tack on a leading
      # zero if necessary
      value = token.value.sub(/\.([eE])/, '.0\1')
      input[:resource] = literal(value, :datatype => RDF::XSD.double)
    end
    terminal(:DECIMAL,              DECIMAL) do |prod, token, input|
      # Note that a Turtle Decimal may begin with a '.', so tack on a leading
      # zero if necessary
      value = token.value
      value = "0#{token.value}" if token.value[0,1] == "."
      input[:resource] = literal(value, :datatype => RDF::XSD.decimal)
    end
    terminal(:INTEGER,              INTEGER) do |prod, token, input|
      input[:resource] = literal(token.value, :datatype => RDF::XSD.integer)
    end
    # Spec confusion: spec says : "Literals , prefixed names and IRIs may also contain escape sequences"
    terminal(:PNAME_LN,             PNAME_LN, :unescape => true) do |prod, token, input|
      prefix, suffix = token.value.split(":", 2)
      input[:resource] = pname(prefix, suffix)
    end
    # Spec confusion: spec says : "Literals , prefixed names and IRIs may also contain escape sequences"
    terminal(:PNAME_NS,             PNAME_NS) do |prod, token, input|
      prefix = token.value[0..-2]

      # Two contexts, one when prefix is being defined, the other when being used
      case prod
      when :prefixID, :sparqlPrefix
        input[:prefix] = prefix
      else
        input[:resource] = pname(prefix, '')
      end
    end
    terminal(:STRING_LITERAL_LONG_SINGLE_QUOTE, STRING_LITERAL_LONG_SINGLE_QUOTE, :unescape => true) do |prod, token, input|
      input[:string_value] = token.value[3..-4]
    end
    terminal(:STRING_LITERAL_LONG_QUOTE, STRING_LITERAL_LONG_QUOTE, :unescape => true) do |prod, token, input|
      input[:string_value] = token.value[3..-4]
    end
    terminal(:STRING_LITERAL_QUOTE,      STRING_LITERAL_QUOTE, :unescape => true) do |prod, token, input|
      input[:string_value] = token.value[1..-2]
    end
    terminal(:STRING_LITERAL_SINGLE_QUOTE,      STRING_LITERAL_SINGLE_QUOTE, :unescape => true) do |prod, token, input|
      input[:string_value] = token.value[1..-2]
    end

    # String terminals
    terminal(nil,                  %r([\{\}\(\),.;\[\]a]|\^\^|true|false)) do |prod, token, input|
      case token.value
      when 'A', 'a'           then input[:resource] = RDF.type
      when 'true', 'false'    then input[:resource] = RDF::Literal::Boolean.new(token.value)
      when '.'                then input[:terminated] = true
      else                         input[:string] = token.value
      end
    end

    terminal(:GRAPH,      /graph/i) do |prod, token, input|
      input[:string_value] = token.value
    end
    terminal(:PREFIX,      PREFIX) do |prod, token, input|
      input[:string_value] = token.value
    end
    terminal(:BASE,      BASE) do |prod, token, input|
      input[:string_value] = token.value
    end

    terminal(:LANGTAG,              LANGTAG) do |prod, token, input|
      input[:lang] = token.value[1..-1]
    end

    # Productions
    # [2g] statement defines the basic creation of context
    start_production(:statement) do |input, current, callback|
      callback.call(:context, "graph", nil)
    end
    production(:statement) do |input, current, callback|
      callback.call(:context, "graph", nil)
    end

    # [6g] graphName
    # Sets the context for triples defined within that graph
    production(:graphName) do |input, current, callback|
      # If input contains set_graph_iri, use the returned value to set @context
      debug("graphName") {"Set graph context to #{current[:resource]}"}
      callback.call(:context, "graphName", current[:resource])
      input[:resource] = current[:resource]
    end

    # [7g] graphName1
    # Sets the context for triples defined within that graph
    production(:graphName1) do |input, current, callback|
      # If input contains set_graph_iri, use the returned value to set @context
      debug("graphName1") {"Set graph context to #{current[:resource]}"}
      callback.call(:context, "graphName1", current[:resource])
      input[:resource] = current[:resource]
    end

    # _tripleOrBareGraph_4 ::= PropertyListNotEmpty '.'
    start_production(:_tripleOrBareGraph_4) do |input, current, callback|
      # Default graph after all
      callback.call(:context, "graph", nil)
      debug("_tripleOrBareGraph_4") {"subject: #{current[:resource]}"}
      current[:subject] = input[:resource]
    end

    # Productions
    # [4] prefixID defines a prefix mapping
    production(:prefixID) do |input, current, callback|
      prefix = current[:prefix]
      iri = current[:resource]
      lexical = current[:string_value]
      terminated = current[:terminated]
      debug("prefixID") {"Defined prefix #{prefix.inspect} mapping to #{iri.inspect}"}
      if lexical.start_with?('@') && lexical != '@prefix'
        error(:prefixID, "should be downcased")
      elsif lexical == '@prefix'
        error(:prefixID, "directive not terminated") unless terminated
      else
        error(:prefixID, "directive should not be terminated") if terminated
      end
      prefix(prefix, iri)
    end

    # [5] base set base_uri
    production(:base) do |input, current, callback|
      iri = current[:resource]
      lexical = current[:string_value]
      terminated = current[:terminated]
      debug("base") {"Defined base as #{iri}"}
      if lexical.start_with?('@') && lexical != '@base'
        error(:base, "should be downcased")
      elsif lexical == '@base'
        error(:base, "directive not terminated") unless terminated
      else
        error(:base, "directive should not be terminated") if terminated
      end
      options[:base_uri] = iri
    end

    # [52s]  TriplesTemplate
    start_production(:TriplesTemplate) do |input, current, callback|
      # Note production as triples for blankNodePropertyList
      # to set :subject instead of :resource
      current[:triples] = true
    end
    production(:TriplesTemplate) do |input, current, callback|
      # Note production as triples for blankNodePropertyList
      # to set :subject instead of :resource
      current[:triples] = true
    end

    # [9] Verb ::= predicate | "a"
    production(:Verb) do |input, current, callback|
      input[:predicate] = current[:resource]
    end

    # [10] subject ::= IRIref | BlankNode | collection
    start_production(:subject) do |input, current, callback|
      current[:triples] = nil
    end

    production(:subject) do |input, current, callback|
      input[:subject] = current[:resource]
    end

    # [12] object ::= iri | BlankNode | collection | BlankNodePropertyList | literal
    production(:object) do |input, current, callback|
      if input[:object_list]
        # Part of an rdf:List collection
        input[:object_list] << current[:resource]
      else
        debug("object") {"current: #{current.inspect}"}
        callback.call(:statement, "object", input[:subject], input[:predicate], current[:resource])
      end
    end

    # [14] BlankNodePropertyList ::= "[" PropertyListNotEmpty "]"
    start_production(:BlankNodePropertyList) do |input, current, callback|
      current[:subject] = self.bnode
    end

    production(:BlankNodePropertyList) do |input, current, callback|
      if input[:triples]
        input[:subject] = current[:subject]
      else
        input[:resource] = current[:subject]
      end
    end

    # [15] collection ::= "(" object* ")"
    start_production(:collection) do |input, current, callback|
      # Tells the object production to collect and not generate statements
      current[:object_list] = []
    end

    production(:collection) do |input, current, callback|
      # Create an RDF list
      objects = current[:object_list]
      list = RDF::List[*objects]
      list.each_statement do |statement|
        next if statement.predicate == RDF.type && statement.object == RDF.List
        callback.call(:statement, "collection", statement.subject, statement.predicate, statement.object)
      end

      # Return bnode as resource
      input[:resource] = list.subject
    end

    # [16] RDFLiteral ::= String ( LanguageTag | ( "^^" IRIref ) )?
    production(:RDFLiteral) do |input, current, callback|
      opts = {}
      opts[:datatype] = current[:resource] if current[:resource]
      opts[:language] = current[:lang] if current[:lang]
      input[:resource] = literal(current[:string_value], opts)
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
                                                 :follow => FOLLOW,
                                                 :reset_on_start => true)
      ) do |context, *data|
        case context
        when :context
          @context = data[1]
        when :statement
          data << @context if @context
          debug("each_statement") {"data: #{data.inspect}, context: #{@context.inspect}"}
          loc = data.shift
          s = RDF::Statement.from(data, :lineno => lineno)
          add_statement(loc, s) unless !s.valid? && validate?
        when :trace
          level, lineno, depth, *args = data
          message = "#{args.join(': ')}"
          d_str = depth > 100 ? ' ' * 100 + '+' : ' ' * depth
          str = "[#{lineno}](#{level})#{d_str}#{message}"
          case @options[:debug]
          when Array
            @options[:debug] << str
          when TrueClass
            $stderr.puts str
          when Integer
            $stderr.puts(str) if level <= @options[:debug]
          end
        end
      end
    rescue EBNF::LL1::Parser::Error => e
      progress("Parsing completed with errors:\n\t#{e.message}")
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
