require 'rdf/turtle'

module RDF::TriG
  ##
  # A TriG serialiser
  #
  # Note that the natural interface is to write a whole repository at a time.
  # Writing statements or Triples will create a repository to add them to
  # and then serialize the repository.
  #
  # @example Obtaining a TriG writer class
  #   RDF::Writer.for(:trig)         #=> RDF::TriG::Writer
  #   RDF::Writer.for("etc/test.trig")
  #   RDF::Writer.for(:file_name      => "etc/test.trig")
  #   RDF::Writer.for(:file_extension => "trig")
  #   RDF::Writer.for(:content_type   => "application/trig")
  #
  # @example Serializing RDF repo into an TriG file
  #   RDF::TriG::Writer.open("etc/test.trig") do |writer|
  #     writer << repo
  #   end
  #
  # @example Serializing RDF statements into an TriG file
  #   RDF::TriG::Writer.open("etc/test.trig") do |writer|
  #     repo.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @example Serializing RDF statements into an TriG string
  #   RDF::TriG::Writer.buffer do |writer|
  #     repo.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # The writer will add prefix definitions, and use them for creating @prefix definitions, and minting QNames
  #
  # @example Creating @base and @prefix definitions in output
  #   RDF::TriG::Writer.buffer(:base_uri => "http://example.com/", :prefixes => {
  #       nil => "http://example.com/ns#",
  #       :foaf => "http://xmlns.com/foaf/0.1/"}
  #   ) do |writer|
  #     repo.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @author [Gregg Kellogg](http://kellogg-assoc.com/)
  class Writer < RDF::Turtle::Writer
    format RDF::TriG::Format
    
    class ContextFilteredRepo
      include RDF::Queryable

      def initialize(repo, context)
        @repo = repo
        @context = context
      end
      
      # Filter statements in repository to those having the specified context
      # Returns each statement having the specified context, `false` for default context
      # @yield statement
      # @yieldparam [RDF::Statement] statement
      # @return [void]
      # @see [RDF::Queryable]
      def each
        @repo.each_statement do |st|
          case @context
          when false
            yield st if !st.context
          else
            yield st if st.context == @context
          end
        end
      end
      
      ##
      # Proxy Repository#query_pattern
      # @see RDF::Repository#query_pattern
      def query_pattern(pattern, &block)
        pattern.context = @context || false
        @repo.send(:query_pattern, pattern, &block)
      end
    end

    ##
    # Initializes the TriG writer instance.
    #
    # @param  [IO, File] output
    #   the output stream
    # @param  [Hash{Symbol => Object}] options
    #   any additional options
    # @option options [Encoding] :encoding     (Encoding::UTF_8)
    #   the encoding to use on the output stream (Ruby 1.9+)
    # @option options [Boolean]  :canonicalize (false)
    #   whether to canonicalize literals when serializing
    # @option options [Hash]     :prefixes     (Hash.new)
    #   the prefix mappings to use (not supported by all writers)
    # @option options [#to_s]    :base_uri     (nil)
    #   the base URI to use when constructing relative URIs
    # @option options [Integer]  :max_depth      (3)
    #   Maximum depth for recursively defining resources, defaults to 3
    # @option options [Boolean]  :standard_prefixes   (false)
    #   Add standard prefixes to @prefixes, if necessary.
    # @option options [String]   :default_namespace (nil)
    #   URI to use as default namespace, same as prefixes[nil]
    # @yield  [writer] `self`
    # @yieldparam  [RDF::Writer] writer
    # @yieldreturn [void]
    # @yield  [writer]
    # @yieldparam [RDF::Writer] writer
    def initialize(output = $stdout, options = {}, &block)
      super do
        # Set both @repo and @graph to a new repository.
        # When serializing a context, @graph is changed
        # to a ContextFilteredRepo
        @repo = @graph = RDF::Repository.new
        if block_given?
          case block.arity
            when 0 then instance_eval(&block)
            else block.call(self)
          end
        end
      end
    end

    ##
    # Outputs the TriG representation of all stored triples.
    #
    # @return [void]
    # @see    #write_triple
    def write_epilogue
      @max_depth = @options[:max_depth] || 3
      @base_uri = RDF::URI(@options[:base_uri])

      reset

      debug {"\nserialize: repo: #{@repo.size}"}

      preprocess
      start_document

      order_contexts.each do |ctx|
        debug {"context: #{ctx.inspect}"}
        reset
        @depth = 2

        if ctx
          @output.write("\n#{format_value(ctx)} {")
        else
          @output.write("\n{")
        end

        # Restrict view to the particular context
        @graph = ContextFilteredRepo.new(@repo, ctx)

        # Pre-process statements again, but in the specified context
        @graph.each {|st| preprocess_statement(st)}
        order_subjects.each do |subject|
          unless is_done?(subject)
            statement(subject)
          end
        end

        @output.puts("}")
      end
    end

    protected
    # Order contexts for output
    def order_contexts
      debug("order_contexts") {@repo.contexts.to_a.inspect}
      contexts = @repo.contexts.to_a.sort
      
      # include default context, if necessary
      contexts.unshift(nil) unless @repo.query(:context => false).to_a.empty?
      
      contexts
    end

    # Perform any statement preprocessing required. This is used to perform reference counts and determine required
    # prefixes.
    # @param [Statement] statement
    def preprocess_statement(statement)
      super
      get_pname(statement.context) if statement.has_context?
    end
  end
end
