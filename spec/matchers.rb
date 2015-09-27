# coding: utf-8
require 'rdf/isomorphic'
require 'json'
JSON_STATE = JSON::State.new(
   :indent       => "  ",
   :space        => " ",
   :space_before => "",
   :object_nl    => "\n",
   :array_nl     => "\n"
 )

 def normalize(repo)
   case repo
   when RDF::Queryable then repo
   when IO, StringIO
     RDF::Repository.new.load(repo, :base_uri => @info.about)
   else
     # Figure out which parser to use
     g = RDF::Repository.new
     reader_class = RDF::Reader.for(:sample => repo)
     reader_class.new(repo, :base_uri => @info.about).each {|s| g << s}
     g
   end
 end

Info = Struct.new(:about, :comment, :debug, :action, :result, :errors)

RSpec::Matchers.define :be_equivalent_dataset do |expected, info|
  match do |actual|
    @info = if info.respond_to?(:input)
      info
    elsif info.is_a?(Hash)
      identifier = info[:identifier] || expected.is_a?(RDF::Graph) ? expected.context : info[:about]
      debug = info[:debug]
      if debug.is_a?(Array)
        debug = debug.map {|s| s.dup.force_encoding(Encoding::UTF_8)}.join("\n")
      end
      Info.new(identifier, info[:comment] || "", debug)
    else
      Info.new(expected.is_a?(RDF::Enumerable) ? expected.context : info, "", info.to_s)
    end
    @expected = normalize(expected)
    @actual = normalize(actual)
    @actual.isomorphic_with?(@expected) rescue false
  end

  failure_message do |actual|
    info = @info.respond_to?(:comment) ? @info.comment : @info.inspect
    if @expected.is_a?(RDF::Queryable) && @actual.size != @expected.size
      "Dataset entry count differs:\nexpected: #{@expected.size}\nactual:   #{@actual.size}"
    elsif @expected.is_a?(Array) && @actual.size != @expected.length
      "Dataset entry count differs:\nexpected: #{@expected.length}\nactual:   #{@actual.size}"
    else
      "Dataset differs"
    end +
    "\n#{info + "\n" unless info.empty?}" +
    (@info.action ? "Input file: #{@info.action}\n" : "") +
    (@info.result ? "Result file: #{@info.result}\n" : "") +
    "Unsorted Expected:\n#{@expected.dump(:nquads)}" +
    "Unsorted Results:\n#{@actual.dump(:nquads)}" +
    (@info.errors && !@info.errors.empty? ? "\nErrors:\n#{@info.errors.join("\n")}\n" : "") +
    (@info.debug ? "\nDebug:\n#{@info.debug}" : "")
  end  
end

RSpec::Matchers.define :match_re do |expected, info|
  match do |actual|
    @info = if info.respond_to?(:about)
      info
    #elsif info.is_a?(Hash)
    #  identifier = info[:identifier] || expected.is_a?(RDF::Graph) ? expected.context : info[:about]
    #  trace = info[:trace]
    #  if trace.is_a?(Array)
    #    trace = trace.map {|s| s.dup.force_encoding(Encoding::UTF_8)}.join("\n")
    #  end
    #  Info.new(identifier, info[:comment] || "", trace)
    else
      Info.new(expected.is_a?(RDF::Graph) ? expected.context : info, info.to_s)
    end
    @expected = expected
    @actual = actual
    @actual.to_s.match(@expected)
  end
  
  failure_message do |actual|
    info = @info.respond_to?(:comment) ? @info.comment : @info.inspect
    "Match failed" +
    "\n#{info + "\n" unless info.empty?}" +
    (@info.action ? "Input file: #{@info.action}\n" : "") +
    (@info.result ? "Output file: #{@info.result}\n" : "") +
    "Expression: #{@expected}\n" +
    "Unsorted Results:\n#{@actual}" +
    (@info.debug ? "\nDebug:\n#{@info.debug}" : "")
  end  
end

RSpec::Matchers.define :produce do |expected, info|
  match do |actual|
    @info = if info.respond_to?(:input)
      info
    else
      Info.new(about: info, comment: "", debug: info.to_s)
    end
    actual == expected
  end
  
  failure_message do |actual|
    "Expected: #{expected.to_json(JSON_STATE)}\n" +
    "Actual  : #{actual.to_json(JSON_STATE)}\n" +
    #(expected.is_a?(Hash) && actual.is_a?(Hash) ? "Diff: #{expected.diff(actual).to_json(JSON_STATE)}\n" : "") +
    (@info.errors && !@info.errors.empty? ? "\nErrors:\n#{@info.errors.join("\n")}\n" : "") +
    "Processing results:\n#{@info.debug.join("\n")}"
  end
end
