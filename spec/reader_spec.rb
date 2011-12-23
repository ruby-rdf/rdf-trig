# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/spec/reader'

describe "RDF::TriG::Reader" do
  before :each do
    @reader = RDF::TriG::Reader.new(StringIO.new(""))
  end

  it_should_behave_like RDF_Reader

  describe ".for" do
    formats = [
      :trig,
      'etc/doap.trig',
      {:file_name      => 'etc/doap.trig'},
      {:file_extension => 'trig'},
      {:content_type   => 'application/trig'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        RDF::Reader.for(arg).should == RDF::TriG::Reader
      end
    end
  end

  context :interface do
    subject {
      %q(
        {<a> <b> [
          a <C>, <D>;
          <has> ("e" <f> _:g)
        ] .}
      )
    }
    
    it "should yield reader" do
      inner = mock("inner")
      inner.should_receive(:called).with(RDF::TriG::Reader)
      RDF::TriG::Reader.new(subject) do |reader|
        inner.called(reader.class)
      end
    end
    
    it "should return reader" do
      RDF::TriG::Reader.new(subject).should be_a(RDF::TriG::Reader)
    end
    
    it "should not raise errors" do
      lambda {
        RDF::TriG::Reader.new(subject, :validate => true)
      }.should_not raise_error
    end

    it "should yield statements" do
      inner = mock("inner")
      inner.should_receive(:called).with(RDF::Statement).exactly(10)
      RDF::TriG::Reader.new(subject).each_statement do |statement|
        inner.called(statement.class)
      end
    end
    
    it "should yield triples" do
      inner = mock("inner")
      inner.should_receive(:called).exactly(10)
      RDF::TriG::Reader.new(subject).each_triple do |subject, predicate, object|
        inner.called(subject.class, predicate.class, object.class)
      end
    end
  end

  describe "with simple default graph" do
    context "simple triple" do
      before(:each) do
        trig = %({<http://example.org/> <http://xmlns.com/foaf/0.1/name> "Gregg Kellogg" .})
        @graph = parse(trig, :validate => true)
        @statement = @graph.statements.first
      end
      
      it "should have a single triple" do
        @graph.size.should == 1
      end
      
      it "should have subject" do
        @statement.subject.to_s.should == "http://example.org/"
      end
      it "should have predicate" do
        @statement.predicate.to_s.should == "http://xmlns.com/foaf/0.1/name"
      end
      it "should have object" do
        @statement.object.to_s.should == "Gregg Kellogg"
      end
    end
    
    # NTriple tests from http://www.w3.org/2000/10/rdf-tests/rdfcore/ntriples/test.nt
    describe "with blank lines" do
      {
        "comment"                   => "# comment lines",
        "comment after whitespace"  => "            # comment after whitespace",
        "empty line"                => "",
        "line with spaces"          => "      "
      }.each_pair do |name, statement|
        specify "test #{name}" do
          parse(statement).size.should == 0
        end
      end
    end

    describe "with literal encodings" do
      {
        'simple literal' => '{<a> <b>  "simple literal" .}',
        'backslash:\\'   => '{<a> <b>  "backslash:\\\\" .}',
        'dquote:"'       => '{<a> <b>  "dquote:\\"" .}',
        "newline:\n"     => '{<a> <b>  "newline:\\n" .}',
        "return\r"       => '{<a> <b>  "return\\r" .}',
        "tab:\t"         => '{<a> <b>  "tab:\\t" .}',
      }.each_pair do |contents, triple|
        specify "test #{triple}" do
          graph = parse(triple, :prefixes => {nil => ''})
          statement = graph.statements.first
          graph.size.should == 1
          statement.object.value.should == contents
        end
      end
      
      {
        'Dürst' => '{<a> <b> "Dürst" .}',
        "é" => '{<a> <b>  "é" .}',
        "€" => '{<a> <b>  "€" .}',
        "resumé" => '{:a :resume  "resumé" .}',
      }.each_pair do |contents, triple|
        specify "test #{triple}" do
          graph = parse(triple, :prefixes => {nil => ''})
          statement = graph.statements.first
          graph.size.should == 1
          statement.object.value.should == contents
        end
      end
      
      it "should parse long literal with escape" do
        trig = %(@prefix : <http://example.org/foo#> . {<a> <b> "\\U00015678another" .})
        if defined?(::Encoding)
          statement = parse(trig).statements.first
          statement.object.value.should == "\u{15678}another"
        else
          pending("Not supported in Ruby 1.8")
        end
      end
      
      context "STRING_LITERAL_LONG" do
        {
          "simple" => %q(foo),
          "muti-line" => %q(
            Foo
            <html:b xmlns:html="http://www.w3.org/1999/xhtml" html:a="b">
              bar
              <rdf:Thing xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                <a:b xmlns:a="foo:"></a:b>
                here
                <a:c xmlns:a="foo:"></a:c>
              </rd
              f:Thing>
            </html:b>
            baz
            <html:i xmlns:html="http://www.w3.org/1999/xhtml">more</html:i>
          ),
        }.each do |test, string|
          it "parses LONG1 #{test}" do
            graph = parse(%({<a> <b> '''#{string}'''}))
            graph.size.should == 1
            graph.statements.first.object.value.should == string
          end

          it "parses LONG2 #{test}" do
            graph = parse(%({<a> <b> """#{string}"""}))
            graph.size.should == 1
            graph.statements.first.object.value.should == string
          end
        end
      end
      
      it "LONG1 matches trailing escaped single-quote" do
        graph = parse(%({<a> <b> '''\\''''}))
        graph.size.should == 1
        graph.statements.first.object.value.should == %q(')
      end
      
      it "LONG2 matches trailing escaped double-quote" do
        graph = parse(%({<a> <b> """\\""""}))
        graph.size.should == 1
        graph.statements.first.object.value.should == %q(")
      end
    end

    it "should create named subject bnode" do
      graph = parse("{_:anon <http://example.org/property> <http://example.org/resource2> .}")
      graph.size.should == 1
      statement = graph.statements.first
      statement.subject.should be_a(RDF::Node)
      statement.subject.id.should =~ /anon/
      statement.predicate.to_s.should == "http://example.org/property"
      statement.object.to_s.should == "http://example.org/resource2"
    end

    it "raises error with anonymous predicate" do
      lambda {
        parse("{<http://example.org/resource2> _:anon <http://example.org/object> .}", :validate => true)
      }.should raise_error RDF::ReaderError
    end

    it "ignores anonymous predicate" do
      g = parse("{<http://example.org/resource2> _:anon <http://example.org/object> .}", :validate => false)
      g.should be_empty
    end

    it "should create named object bnode" do
      graph = parse("{<http://example.org/resource2> <http://example.org/property> _:anon .}")
      graph.size.should == 1
      statement = graph.statements.first
      statement.subject.to_s.should == "http://example.org/resource2"
      statement.predicate.to_s.should == "http://example.org/property"
      statement.object.should be_a(RDF::Node)
      statement.object.id.should =~ /anon/
    end

    it "should allow mixed-case language" do
      trig = %({:x2 :p "xyz"@EN .})
      statement = parse(trig, :prefixes => {nil => ''}).statements.first
      statement.object.to_ntriples.should == %("xyz"@EN)
    end

    it "should create typed literals" do
      trig = "{<http://example.org/joe> <http://xmlns.com/foaf/0.1/name> \"Joe\" .}"
      statement = parse(trig).statements.first
      statement.object.class.should == RDF::Literal
    end

    it "should create BNodes" do
      trig = "{_:a a _:c .}"
      statement = parse(trig).statements.first
      statement.subject.class.should == RDF::Node
      statement.object.class.should == RDF::Node
    end

    describe "IRIs" do
      {
        %({<http://example.org/joe> <http://xmlns.com/foaf/0.1/knows> <http://example.org/jane> .}) =>
          %(<http://example.org/joe> <http://xmlns.com/foaf/0.1/knows> <http://example.org/jane> .),
        %(@base <http://a/b> . {<joe> <knows> <#jane> .}) =>
          %(<http://a/joe> <http://a/knows> <http://a/b#jane> .),
        %(@base <http://a/b#> . {<joe> <knows> <#jane> .}) =>
          %(<http://a/joe> <http://a/knows> <http://a/b#jane> .),
        %(@base <http://a/b/> . {<joe> <knows> <#jane> .}) =>
          %(<http://a/b/joe> <http://a/b/knows> <http://a/b/#jane> .),
        %(@base <http://a/b/> . {</joe> <knows> <jane> .}) =>
          %(<http://a/joe> <http://a/b/knows> <http://a/b/jane> .),
      }.each_pair do |trig, nt|
        it "for '#{trig}'" do
          parse(trig).should be_equivalent_graph(nt, :trace => @debug)
        end
      end

      {
        %({<#Dürst> <knows> <jane>.}) => '<#D\u00FCrst> <knows> <jane> .',
        %({<Dürst> <knows> <jane>.}) => '<D\u00FCrst> <knows> <jane> .',
        %({<bob> <resumé> "Bob's non-normalized resumé".}) => '<bob> <resumé> "Bob\'s non-normalized resumé" .',
        %({<alice> <resumé> "Alice's normalized resumé".}) => '<alice> <resumé> "Alice\'s normalized resumé" .',
        }.each_pair do |trig, nt|
          it "for '#{trig}'" do
            begin
              parse(trig).should be_equivalent_graph(nt, :trace => @debug)
            rescue
              if defined?(::Encoding)
                raise
              else
                pending("Unicode URIs not supported in Ruby 1.8") {  raise } 
              end
            end
          end
        end

      {
        %({<#Dürst> a  "URI straight in UTF8".}) => %(<#D\\u00FCrst> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> "URI straight in UTF8" .),
        %({<a> :related :ひらがな .}) => %(<a> <related> <\\u3072\\u3089\\u304C\\u306A> .),
      }.each_pair do |trig, nt|
        it "for '#{trig}'" do
          begin
            parse(trig, :prefixes => {nil => ''}).should be_equivalent_graph(nt, :trace => @debug)
          rescue
            if defined?(::Encoding)
              raise
            else
              pending("Unicode URIs not supported in Ruby 1.8") {  raise } 
            end
          end
        end
      end

      [
        %(\x00),
        %(\x01),
        %(\x0f),
        %(\x10),
        %(\x1f),
        %(\x20),
        %(<),
        %(>),
        %("),
        %({),
        %(}),
        %(|),
        %(\\),
        %(^),
        %(``),
      ].each do |uri|
        it "rejects #{uri.inspect}" do
          lambda {parse(%({<#{uri}> <uri> "#{uri} .}"), :validate => true)}.should raise_error RDF::ReaderError
        end
      end
    end
  end
  
  describe "with TriG grammar" do
    describe "named graphs" do
      it "iri" do
        trig = %(<C> {<a> <b> <c> .})
        nq = %(<a> <b> <c> <C>.)
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "undefined prefix" do
        trig = %(:C {:a :b :c .})
        nq = %(<a> <b> <c> <C>.)
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "duplicated named graphs" do
        
      end
    end

    describe "@prefix" do
      it "raises an error when validating if not defined" do
        trig = %({<a> a :a .})
        lambda {parse(trig, :validate => true)}.should raise_error(RDF::ReaderError)
      end
      
      it "allows undefined empty prefix if not validating" do
        trig = %({:a :b :c .})
        nq = %(<a> <b> <c> .)
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "empty relative-IRI" do
        trig = %(@prefix foo: <> . {<a> a foo:a.})
        nq = %(<a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <a> .)
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "<#> as a prefix and as a triple node" do
        trig = %(@prefix : <#> . {<#> a :a.})
        nq = %(
        <#> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <#a> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
      
      it "ignores _ as prefix identifier" do
        trig = %(
        {_:a a :p.}
        @prefix _: <http://underscore/> .
        {_:a a :q.}
        )
        nq = %(
        _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <p> .
        _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <q> .
        )
        lambda {parse(trig, :validate => true)}.should raise_error(RDF::ReaderError)
        parse(trig, :validate => false).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "redefine" do
        trig = %(
        @prefix a: <http://host/A#>.
        {a:b a:p a:v .}

        @prefix a: <http://host/Z#>.
        {a:b a:p a:v .}
        )
        nq = %(
        <http://host/A#b> <http://host/A#p> <http://host/A#v> .
        <http://host/Z#b> <http://host/Z#p> <http://host/Z#v> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "returns defined prefixes" do
        trig = %(
        @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix : <http://test/> .
        {
          :foo a rdfs:Class.
          :bar :d :c.
          :a :d :c.
        }
        )
        reader = RDF::TriG::Reader.new(trig)
        reader.each {|statement|}
        reader.prefixes.should == {
          :rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
          nil => "http://test/"}
      end
    end

    describe "@base" do
      it "sets absolute base" do
        trig = %(@base <http://foo/bar> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar> <http://foo/a> <http://foo/b> .
        <http://foo/bar#c> <http://foo/d> <http://foo/e> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
      
      it "sets absolute base (trailing /)" do
        trig = %(@base <http://foo/bar/> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar/> <http://foo/bar/a> <http://foo/bar/b> .
        <http://foo/bar/#c> <http://foo/bar/d> <http://foo/e> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
      
      it "should set absolute base (trailing #)" do
        trig = %(@base <http://foo/bar#> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar#> <http://foo/a> <http://foo/b> .
        <http://foo/bar#c> <http://foo/d> <http://foo/e> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
      
      it "sets a relative base" do
        trig = %(
        @base <http://example.org/products/>.
        {<> <a> <b>, <#c>.}
        @base <prod123/>.
        {<> <a> <b>, <#c>.}
        @base <../>.
        {<> <a> <d>, <#e>.}
        )
        nq = %(
        <http://example.org/products/> <http://example.org/products/a> <http://example.org/products/b> .
        <http://example.org/products/> <http://example.org/products/a> <http://example.org/products/#c> .
        <http://example.org/products/prod123/> <http://example.org/products/prod123/a> <http://example.org/products/prod123/b> .
        <http://example.org/products/prod123/> <http://example.org/products/prod123/a> <http://example.org/products/prod123/#c> .
        <http://example.org/products/> <http://example.org/products/a> <http://example.org/products/d> .
        <http://example.org/products/> <http://example.org/products/a> <http://example.org/products/#e> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
      
      it "redefine" do
        trig = %(
        @base <http://example.com/ontolgies>.
        {<a> <b> <foo/bar#baz>.}
        @base <path/DIFFERENT/>.
        {<a2> <b2> <foo/bar#baz2>.}
        @prefix : <#>.
        {<d3> :b3 <e3>.}
        )
        nq = %(
        <http://example.com/a> <http://example.com/b> <http://example.com/foo/bar#baz> .
        <http://example.com/path/DIFFERENT/a2> <http://example.com/path/DIFFERENT/b2> <http://example.com/path/DIFFERENT/foo/bar#baz2> .
        <http://example.com/path/DIFFERENT/d3> <http://example.com/path/DIFFERENT/#b3> <http://example.com/path/DIFFERENT/e3> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
    end
    
    describe "objectList" do
      it "IRIs" do
        trig = %({<a> <b> <c>, <d>})
        nq = %(
          <a> <b> <c> .
          <a> <b> <d> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "literals" do
        trig = %({<a> <b> "1", "2" .})
        nq = %(
          <a> <b> "1" .
          <a> <b> "2" .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end

      it "mixed" do
        trig = %({<a> <b> <c>, "2" .})
        nq = %(
          <a> <b> <c> .
          <a> <b> "2" .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
    end
    
    describe "predicateObjectList" do
      it "does that" do
        trig = %(
        @prefix a: <http://foo/a#> .

        {
          a:b a:p1 "123" ; a:p1 "456" .
          a:b a:p2 a:v1 ; a:p3 a:v2 .
        }
        )
        nq = %(
        <http://foo/a#b> <http://foo/a#p1> "123" .
        <http://foo/a#b> <http://foo/a#p1> "456" .
        <http://foo/a#b> <http://foo/a#p2> <http://foo/a#v1> .
        <http://foo/a#b> <http://foo/a#p3> <http://foo/a#v2> .
        )
        parse(trig).should be_equivalent_graph(nq, :trace => @debug)
      end
    end
  end

  describe "validation" do
    {
      %({<a> <b> "xyz"^^<http://www.w3.org/2001/XMLSchema#integer> .}) => %r("xyz" is not a valid .*),
      # FIXME: more invalid TriX
    }.each_pair do |trig, error|
      it "should raise '#{error}' for '#{trig}'" do
        lambda {
          parse("@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{trig}", :base_uri => "http://a/b", :validate => true)
        }.should raise_error(error)
      end
    end
  end
  
  describe "recovery" do
    {
      "statements outside of a graph" => [
        %q(<a> <b> <c> .),
        %q()
      ],
      "base within a graph" => [
        %q({ @base <http://example.com/> . <a> <b> <c>}),
        %q(<a> <b> <c>)
      ],
      "prefix within a graph" => [
        %q({ @prefix foo: <http://example.com/> . foo:a foo:b foo:c}),
        %q(<a> <b> <c>)
      ],
      "BNode graph identifier" => [
        %q(_:a {<a> <b> <c> .}),
        %q(<a> <b> <c> .)
      ],
      "Literal graph identifier" => [
        %q("a" {<a> <b> <c> .}),
        %q(<a> <b> <c> .)
      ],
      "malformed bnode subject" => [
        %q({_:.1 <a> <b> . _:bn <a> <c> .}),
        %q(_:bn <a> <c> .)
      ],
      "malformed bnode object(1)" => [
        %q({<a> <b> _:.1 . <a> <c> <d> .}),
        %q(<a> <c> <d> .)
      ],
      "malformed bnode object(2)" => [
        %q({<a> <b> _:-a; <c> <d> .}),
        %q(<a> <c> <d> .)
      ],
      "malformed bnode object(3)" => [
        %q({<a> <b> _:-a, <d> .}),
        %q(<a> <b> <d> .)
      ],
      "malformed uri subject" => [
        %q({<"quoted"> <a> <b> . <c> <d> <e> .}),
        %q(<c> <d> <e> .)
      ],
      "malformed uri predicate(1)" => [
        %q({<a> <"quoted"> <b> . <c> <d> <e> .}),
        %q(<c> <d> <e> .)
      ],
      "malformed uri predicate(2)" => [
        %q({<a> <"quoted"> <b>; <d> <e> .}),
        %q(<d> <d> <e> .)
      ],
      "malformed uri object(1)" => [
        %q({<a> <b> <"quoted"> . <c> <d> <e> .}),
        %q(<c> <d> <e> .)
      ],
      "malformed uri object(2)" => [
        %q({<a> <b> <"quoted">; <d> <e> .}),
        %q(<d> <d> <e> .)
      ],
      "malformed uri object(3)" => [
        %q({<a> <b> "quoted">, <e> .}),
        %q(<a> <b> <e> .)
      ],
    }.each do |test, (input, expected)|
      context test do
        it "raises an error if valiating" do
          lambda {
            parse(input, :validate => true)
          }.should raise_error
        end
        
        it "continues after an error", :pending => true do
          parse(input, :validate => false).should be_equivalent_graph(expected, :trace => @debug)
        end
      end
    end
  end
  
  describe "spec examples" do
    {
      "example 1" => [
        %q(
          # This document encodes three graphs.

          @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
          @prefix swp: <http://www.w3.org/2004/03/trix/swp-1/> .
          @prefix dc: <http://purl.org/dc/elements/1.1/> .
          @prefix ex: <http://www.example.org/vocabulary#> .
          @prefix : <http://www.example.org/exampleDocument#> .

          :G1 { :Monica ex:name "Monica Murphy" .      
                :Monica ex:homepage <http://www.monicamurphy.org> .
                :Monica ex:email <mailto:monica@monicamurphy.org> .
                :Monica ex:hasSkill ex:Management }

          :G2 { :Monica rdf:type ex:Person .
                :Monica ex:hasSkill ex:Programming }

          :G3 { :G1 swp:assertedBy _:w1 .
                _:w1 swp:authority :Chris .
                _:w1 dc:date "2003-10-02"^^xsd:date .   
                :G2 swp:quotedBy _:w2 .
                :G3 swp:assertedBy _:w2 .
                _:w2 dc:date "2003-09-03"^^xsd:date .
                _:w2 swp:authority :Chris .
                :Chris rdf:type ex:Person .  
                :Chris ex:email <mailto:chris@bizer.de> }
        ),
        %q(
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#name> "Monica Murphy" <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#homepage> <http://www.monicamurphy.org> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#email> <mailto:monica@monicamurphy.org> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#hasSkill> <http://www.example.org/vocabulary#Management> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#hasSkill> <http://www.example.org/vocabulary#Programming> <http://www.example.org/exampleDocument#G2> .
        <http://www.example.org/exampleDocument#Monica> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.example.org/vocabulary#Person> <http://www.example.org/exampleDocument#G2> .
        <http://www.example.org/exampleDocument#G1> <http://www.w3.org/2004/03/trix/swp-1/assertedBy> _:w1 <http://www.example.org/exampleDocument#G3> .
        _:w1 <http://www.w3.org/2004/03/trix/swp-1/authority> <http://www.example.org/exampleDocument#Chris> <http://www.example.org/exampleDocument#G3> .
        _:w1 <http://purl.org/dc/elements/1.1/date> "2003-10-02"^^<http://www.w3.org/2001/XMLSchema#date>  <http://www.example.org/exampleDocument#G3> .
        <http://www.example.org/exampleDocument#G2> <http://www.w3.org/2004/03/trix/swp-1/quotedBy> _:w2 <http://www.example.org/exampleDocument#G3> .
        <http://www.example.org/exampleDocument#G3> <http://www.w3.org/2004/03/trix/swp-1/assertedBy> _:w2 <http://www.example.org/exampleDocument#G3> .
        _:w2 <http://purl.org/dc/elements/1.1/date> "2003-09-03"^^<http://www.w3.org/2001/XMLSchema#date> <http://www.example.org/exampleDocument#G3> .
        _:w2 <http://www.w3.org/2004/03/trix/swp-1/authority> <http://www.example.org/exampleDocument#Chris> <http://www.example.org/exampleDocument#G3> .
        <http://www.example.org/exampleDocument#Chris> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.example.org/vocabulary#Person> <http://www.example.org/exampleDocument#G3> .
        <http://www.example.org/exampleDocument#Chris> <http://www.example.org/vocabulary#email> <mailto:chris@bizer.de> <http://www.example.org/exampleDocument#G3> .
        )
      ],
      "example 2" => [
        %q(
          # This document encodes one graph.
          @prefix ex: <http://www.example.org/vocabulary#> .
          @prefix : <http://www.example.org/exampleDocument#> .

          :G1 { :Monica a ex:Person ;
                        ex:name "Monica Murphy" ;      
                        ex:homepage <http://www.monicamurphy.org> ;
                        ex:email <mailto:monica@monicamurphy.org> ;
                        ex:hasSkill ex:Management ,
                                    ex:Programming . }        
        ),
        %q(
        <http://www.example.org/exampleDocument#Monica> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.example.org/vocabulary#Person> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#name> "Monica Murphy" <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#homepage> <http://www.monicamurphy.org> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#email> <mailto:monica@monicamurphy.org> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#hasSkill> <http://www.example.org/vocabulary#Management> <http://www.example.org/exampleDocument#G1> .
        <http://www.example.org/exampleDocument#Monica> <http://www.example.org/vocabulary#hasSkill> <http://www.example.org/vocabulary#Programming> <http://www.example.org/exampleDocument#G1> .
        )
      ],
      "example 3" => [
        %q(
          # This document contains a default graph and two named graphs.

          @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix dc: <http://purl.org/dc/elements/1.1/> .
          @prefix foaf: <http://xmlns.com/foaf/0.1/> .

          # default graph
              { 
                <http://example.org/bob> dc:publisher "Bob" . 
                <http://example.org/alice> dc:publisher "Alice" .
              }

          <http://example.org/bob> 
              { 
                 _:a foaf:name "Bob" . 
                 _:a foaf:mbox <mailto:bob@oldcorp.example.org> .
              }

          <http://example.org/alice>
              { 
                 _:a foaf:name "Alice" . 
                 _:a foaf:mbox <mailto:alice@work.example.org> .
              }
        ),
        %q(
        <http://example.org/bob> <http://purl.org/dc/elements/1.1/publisher> "Bob" .
        <http://example.org/alice> <http://purl.org/dc/elements/1.1/publisher> "Alice" .
        _:a <http://xmlns.com/foaf/0.1/name> "Bob" <http://example.org/bob> .
        _:a <http://xmlns.com/foaf/0.1/mbox> <mailto:bob@oldcorp.example.org> <http://example.org/bob> .
        _:a <http://xmlns.com/foaf/0.1/name> "Alice" <http://example.org/alice> .
        _:a <http://xmlns.com/foaf/0.1/mbox> <mailto:alice@work.example.org> <http://example.org/alice> .
        )
      ],
    }.each do |name, (input, expected)|
      it "matches TriG spec #{name}" do
        parse(input).should be_equivalent_graph(expected, :trace => @debug)
      end
    end
  end

  def parse(input, options = {})
    @debug = []
    options = {
      :debug => @debug,
      :validate => false,
      :canonicalize => false,
    }.merge(options)
    graph = options[:graph] || RDF::Repository.new
    RDF::TriG::Reader.new(input, options).each do |statement|
      graph << statement
    end
    graph
  end
end
