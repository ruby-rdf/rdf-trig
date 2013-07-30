module RDF::TriG
  ##
  # Streaming writer interface
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  module StreamingWriter
    ##
    # Write out a statement, retaining current
    # `subject` and `predicate` to create more compact output
    # @return [void] `self`
    def stream_statement(statement)
      if statement.context != @streaming_context
        stream_epilogue
        if statement.context
          @output.write "#{format_term(statement.context)} {"
        else
          @output.write "{"
        end
        @streaming_context, @streaming_subject, @streaming_predicate = statement.context, statement.subject, statement.predicate
        @output.write "#{format_term(statement.subject)} "
        @output.write "#{format_term(statement.predicate)} "
      elsif statement.subject != @streaming_subject
        @output.write " .\n#{indent(1)}" if @streaming_subject
        @streaming_subject, @streaming_predicate = statement.subject, statement.predicate
        @output.write "#{format_term(statement.subject)} "
        @output.write "#{format_term(statement.predicate)} "
      elsif statement.predicate != @streaming_predicate
        @streaming_predicate = statement.predicate
        @output.write ";\n#{indent(2)}#{format_term(statement.predicate)} "
      else
        @output.write ",\n#{indent(3)}"
      end
      @output.write("#{format_term(statement.object)}")
    end

    ##
    # Complete open statements
    # @return [void] `self`
    def stream_epilogue
      @output.puts " }" if @streaming_context != :none
    end

    private
  end
end
