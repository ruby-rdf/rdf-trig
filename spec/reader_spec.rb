# coding: utf-8
$:.unshift "."
require 'spec_helper'
require 'rdf/spec/reader'

describe "RDF::TriG::Reader" do
  let!(:doap) {File.expand_path("../../etc/doap.trig", __FILE__)}
  let!(:doap_nq) {File.expand_path("../../etc/doap.nq", __FILE__)}
  let!(:doap_count) {File.open(doap_nq).each_line.to_a.length}


  it_behaves_like 'an RDF::Reader' do
    let(:reader) {RDF::TriG::Reader.new}
    let(:reader_input) {File.read(doap)}
    let(:reader_count) {doap_count}
  end

  describe ".for" do
    [
      :trig,
      'etc/doap.trig',
      {:file_name      => 'etc/doap.trig'},
      {file_extension: 'trig'},
      {:content_type   => 'application/trig'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Reader.for(arg)).to eq RDF::TriG::Reader
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
      expect {|b| RDF::TriG::Reader.new(subject, &b)}.to yield_control.exactly(1).times
    end
    
    it "should return reader" do
      expect(RDF::TriG::Reader.new(subject)).to be_a(RDF::TriG::Reader)
    end
    
    it "should not raise errors" do
      expect {
        RDF::TriG::Reader.new(subject, validate: true)
      }.to_not raise_error
    end

    it "should yield statements" do
      expect {|b| RDF::TriG::Reader.new(subject).each_statement(&b)}.
        to yield_control.exactly(10).times

      RDF::TriG::Reader.new(subject).each_statement do |s|
        expect(s).to be_statement
      end
    end
    
    it "should yield triples" do
      expect {|b| RDF::TriG::Reader.new(subject).each_triple(&b)}.
        to yield_control.exactly(10).times

      RDF::TriG::Reader.new(subject).each_triple do |s, p, o|
        expect(s).to be_resource
        expect(p).to be_uri
        expect(o).to be_term
      end
    end
  end

  describe "with simple default graph" do
    context "simple triple" do
      before(:each) do
        trig = %({<http://example.org/> <http://xmlns.com/foaf/0.1/name> "Gregg Kellogg" .})
        @graph = parse(trig, validate: true)
        @statement = @graph.statements.to_a.first
      end
      
      it "should have a single triple" do
        expect(@graph.size).to eq 1
      end
      
      it "should have subject" do
        expect(@statement.subject.to_s).to eq "http://example.org/"
      end
      it "should have predicate" do
        expect(@statement.predicate.to_s).to eq "http://xmlns.com/foaf/0.1/name"
      end
      it "should have object" do
        expect(@statement.object.to_s).to eq "Gregg Kellogg"
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
          expect(parse(statement).size).to eq 0
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
          graph = parse(triple, prefixes: {nil => ''})
          statement = graph.statements.to_a.first
          expect(graph.size).to eq 1
          expect(statement.object.value).to eq contents
        end
      end
      
      {
        'Dürst' => '{<a> <b> "Dürst" .}',
        "é" => '{<a> <b>  "é" .}',
        "€" => '{<a> <b>  "€" .}',
        "resumé" => '{:a :resume  "resumé" .}',
      }.each_pair do |contents, triple|
        specify "test #{triple}" do
          graph = parse(triple, prefixes: {nil => ''})
          statement = graph.statements.to_a.first
          expect(graph.size).to eq 1
          expect(statement.object.value).to eq contents
        end
      end
      
      it "should parse long literal with escape" do
        trig = %(@prefix : <http://example.org/foo#> . {<a> <b> "\\U00015678another" .})
        if defined?(::Encoding)
          statement = parse(trig).statements.to_a.first
          expect(statement.object.value).to eq "\u{15678}another"
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
            graph = parse(%({<a> <b> '''#{string}'''.}))
            expect(graph.size).to eq 1
            expect(graph.statements.to_a.first.object.value).to eq string
          end

          it "parses LONG2 #{test}" do
            graph = parse(%({<a> <b> """#{string}""".}))
            expect(graph.size).to eq 1
            expect(graph.statements.to_a.first.object.value).to eq string
          end
        end
      end
      
      it "LONG1 matches trailing escaped single-quote" do
        graph = parse(%({<a> <b> '''\\''''.}))
        expect(graph.size).to eq 1
        expect(graph.statements.to_a.first.object.value).to eq %q(')
      end
      
      it "LONG2 matches trailing escaped double-quote" do
        graph = parse(%({<a> <b> """\\"""".}))
        expect(graph.size).to eq 1
        expect(graph.statements.to_a.first.object.value).to eq %q(")
      end
    end

    it "should create named subject bnode" do
      graph = parse("{_:anon <http://example.org/property> <http://example.org/resource2> .}")
      expect(graph.size).to eq 1
      statement = graph.statements.to_a.first
      expect(statement.subject).to be_a(RDF::Node)
      expect(statement.subject.id).to match(/anon/)
      expect(statement.predicate.to_s).to eq "http://example.org/property"
      expect(statement.object.to_s).to eq "http://example.org/resource2"
    end

    it "raises error with anonymous predicate" do
      expect {
        parse("{<http://example.org/resource2> _:anon <http://example.org/object> .}", validate: true)
      }.to raise_error RDF::ReaderError
    end

    it "ignores anonymous predicate" do
      g = parse("{<http://example.org/resource2> _:anon <http://example.org/object> .}", validate: false)
      expect(g).to be_empty
    end

    it "should create named object bnode" do
      graph = parse("{<http://example.org/resource2> <http://example.org/property> _:anon .}")
      expect(graph.size).to eq 1
      statement = graph.statements.to_a.first
      expect(statement.subject.to_s).to eq "http://example.org/resource2"
      expect(statement.predicate.to_s).to eq "http://example.org/property"
      expect(statement.object).to be_a(RDF::Node)
      expect(statement.object.id).to match(/anon/)
    end

    it "should allow mixed-case language" do
      trig = %({:x2 :p "xyz"@en .})
      statement = parse(trig, prefixes: {nil => ''}).statements.to_a.first
      expect(statement.object.to_ntriples).to eq %("xyz"@en)
    end

    it "should create typed literals" do
      trig = "{<http://example.org/joe> <http://xmlns.com/foaf/0.1/name> \"Joe\" .}"
      statement = parse(trig).statements.to_a.first
      expect(statement.object).to be_a RDF::Literal
    end

    it "should create BNodes" do
      trig = "{_:a a _:c .}"
      statement = parse(trig).statements.to_a.first
      expect(statement.subject).to be_a RDF::Node
      expect(statement.object).to be_a RDF::Node
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
          expect(parse(trig)).to be_equivalent_graph(nt, logger: @logger)
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
              expect(parse(trig)).to be_equivalent_graph(nt, logger: @logger)
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
            expect(parse(trig, prefixes: {nil => ''})).to be_equivalent_graph(nt, logger: @logger)
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
          expect {parse(%({<#{uri}> <uri> "#{uri} .}"), validate: true)}.to raise_error RDF::ReaderError
        end
      end
    end
  end
  
  describe "with TriG grammar" do
    describe "named graphs" do
      it "iri" do
        trig = %(<C> {<a> <b> <c> .})
        nq = %(<a> <b> <c> <C>.)
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "BNode" do
        trig = %(_:graph {<a> <b> <c> .})
        nq = RDF::Repository.new << RDF::NQuads::Reader.new(%(<a> <b> <c> _:graph .))
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "undefined prefix" do
        trig = %(:C {:a :b :c .})
        nq = %(<a> <b> <c> <C>.)
        expect(parse(trig, validate: false)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "alternating graphs" do
        trig = %(
          @prefix : <> .
          {:a :b :c.}
          :G {:a :b :d.}
          {:a :b :e.}
          :G {:a :b :f.}
        )
        nq = RDF::Repository.new << RDF::NQuads::Reader.new(%(
          <a> <b> <c> .
          <a> <b> <d> <G> .
          <a> <b> <e> .
          <a> <b> <f> <G> .
        ))
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "alternating graphs (BNodes)" do
        trig = %(
          @prefix : <> .
          {:a :b :c.}
          _:G {:a :b :d.}
          {:a :b :e.}
          _:G {:a :b :f.}
        )
        nq = RDF::Repository.new << RDF::NQuads::Reader.new(%(
          <a> <b> <c> .
          <a> <b> <d> _:G .
          <a> <b> <e> .
          <a> <b> <f> _:G .
        ))
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "no closing ." do
        trig = %({<a> <b> <c>, "2"})
        nq = %(
          <a> <b> <c> .
          <a> <b> "2" .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end
    end

    describe "GRAPH" do
      {
        %(GRAPH <g> {<s> <p> <o>}) => %(<s> <p> <o> <g> .),
        %(graph <g> {<s> <p> <o>}) => %(<s> <p> <o> <g> .),
        %(GRAPH <g> {<s> <p> <o> .}) => %(<s> <p> <o> <g> .),
        %(GRAPH <g> {}) => %(),
        %(PREFIX : <http://example/>
          GRAPH :g1 {:s :p :o}
          GRAPH :g2 {:s :p :o}
          :g3 {:s :p :o}
          graph :g4 {:s :p :o}
          graph :g5 {:s :p :o}) => %(
          <http://example/s> <http://example/p> <http://example/o> <http://example/g1> .
          <http://example/s> <http://example/p> <http://example/o> <http://example/g2> .
          <http://example/s> <http://example/p> <http://example/o> <http://example/g3> .
          <http://example/s> <http://example/p> <http://example/o> <http://example/g4> .
          <http://example/s> <http://example/p> <http://example/o> <http://example/g5> .
        ),
        %(GRAPH _:a {<s> <p> <o> .}) => %(<s> <p> <o> _:a .),
        %(PREFIX : <http://example/>
          GRAPH [] {:s :p :o}
          [] {:s :p :o}
          graph [] {:s :p :o}) => %(
          <http://example/s> <http://example/p> <http://example/o> _:a .
          <http://example/s> <http://example/p> <http://example/o> _:b .
          <http://example/s> <http://example/p> <http://example/o> _:c .
        ),
      }.each do |trig, nq|
        it "generates #{nq} from #{trig}" do
          res = RDF::Repository.new << RDF::NQuads::Reader.new(nq)
          expect(parse(trig)).to be_equivalent_graph(res, logger: @logger)
        end
      end
    end

    describe "Turtle as Trig" do
      {
        %(<s> <p> <o>; <q> 123, 456 .
          <s1> <p1> "more" .
        ) => %(
          <s> <p> <o> .
          <s> <q> "123"^^<http://www.w3.org/2001/XMLSchema#integer> .
          <s> <q> "456"^^<http://www.w3.org/2001/XMLSchema#integer> .
          <s1> <p1> "more" .
        ),
        %([ <p> <o> ] .) => %(_:s <p> <o> .),
        %(prefix : <http://example/>
          [ :p :o ] .) => %(_:s <http://example/p> <http://example/o> .),
      }.each do |trig, nq|
        it "generates #{nq} from #{trig}" do
          res = RDF::Repository.new << RDF::NQuads::Reader.new(nq)
          expect(parse(trig)).to be_equivalent_graph(res, logger: @logger)
        end
      end
    end

    describe "@prefix" do
      it "raises an error when validating if not defined" do
        trig = %({<a> a :a .})
        expect {parse(trig, validate: true)}.to raise_error(RDF::ReaderError)
      end
      
      it "allows undefined empty prefix if not validating" do
        trig = %({:a :b :c .})
        nq = %(<a> <b> <c> .)
        expect(parse(trig, validate: false)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "empty relative-IRI" do
        trig = %(@prefix foo: <> . {<a> a foo:a.})
        nq = %(<a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <a> .)
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "<#> as a prefix and as a triple node" do
        trig = %(@prefix : <#> . {<#> a :a.})
        nq = %(
        <#> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <#a> .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
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
        expect {parse(trig, validate: true)}.to raise_error(RDF::ReaderError)
        expect(parse(trig, validate: false)).to be_equivalent_graph(nq, logger: @logger)
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
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
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
        expect(reader.prefixes).to eq({
          rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
          rdfs: "http://www.w3.org/2000/01/rdf-schema#",
          nil => "http://test/"})
      end
    end

    describe "@base" do
      it "sets absolute base" do
        trig = %(@base <http://foo/bar> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar> <http://foo/a> <http://foo/b> .
        <http://foo/bar#c> <http://foo/d> <http://foo/e> .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end
      
      it "sets absolute base (trailing /)" do
        trig = %(@base <http://foo/bar/> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar/> <http://foo/bar/a> <http://foo/bar/b> .
        <http://foo/bar/#c> <http://foo/bar/d> <http://foo/e> .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end
      
      it "should set absolute base (trailing #)" do
        trig = %(@base <http://foo/bar#> . {<> <a> <b> . <#c> <d> </e>.})
        nq = %(
        <http://foo/bar#> <http://foo/a> <http://foo/b> .
        <http://foo/bar#c> <http://foo/d> <http://foo/e> .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
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
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
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
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end
    end
    
    describe "objectList" do
      it "IRIs" do
        trig = %({<a> <b> <c>, <d>.})
        nq = %(
          <a> <b> <c> .
          <a> <b> <d> .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "literals" do
        trig = %({<a> <b> "1", "2" .})
        nq = %(
          <a> <b> "1" .
          <a> <b> "2" .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "mixed" do
        trig = %({<a> <b> <c>, "2" .})
        nq = %(
          <a> <b> <c> .
          <a> <b> "2" .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "optional closing ," do
        trig = %({<a> <b> <c>, "2",})
        nq = %(
          <a> <b> <c> .
          <a> <b> "2" .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
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
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end

      it "optional closing ;" do
        trig = %({<a> <b> <c>, "2";})
        nq = %(
          <a> <b> <c> .
          <a> <b> "2" .
        )
        expect(parse(trig)).to be_equivalent_graph(nq, logger: @logger)
      end
    end
    
    describe "RDF Collection" do
      {
        "empty collection" => [
          %(
            @prefix a: <http://foo/a#> .

            a:U {
              a:b a:p0 () .
            }
          ),
          %(
            <http://foo/a#b> <http://foo/a#p0> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://foo/a#U> .
          )
        ],
        "Single entry" => [
          %(
            @prefix a: <http://foo/a#> .

            a:U {
              a:b a:p0 ("123") .
            }
          ),
          %(
            <http://foo/a#b> <http://foo/a#p0> _:a <http://foo/a#U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "123" <http://foo/a#U> .
            _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://foo/a#U> .
          )
        ],
        "as subject" => [
          %(
            @prefix : <http://ex/#> .
            ("123") :p :o
          ),
          %(
            _:s <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "123" .
            _:s <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
            _:s <http://ex/#p> <http://ex/#o> .
          )
        ]
      }.each do |name, (trig, nq)|
        it name do
          res = RDF::Repository.new << RDF::NQuads::Reader.new(nq)
          expect(parse(trig)).to be_equivalent_graph(res, logger: @logger)
        end
      end
    end
  end

  describe "validation" do
    let(:errors) {[]}
    {
      %({<a> <b> "xyz"^^<http://www.w3.org/2001/XMLSchema#integer> .}) => %r("xyz" is not a valid .*),
      %(GRAPH {<s> <p> <o>}) => %r(Expected label or subject),
      %(GRAPH <g> {<s> <p> <o>} .) => %r(Unexpected token),
      %(GRAPH <g> <s> <p> <o> .) => %r(Expected wrappedGraph),
      %(GRAPH <s> <p> <o> .) => %r(Expected wrappedGraph),
      %(GRAPH <g1> <g2> {<s> <p> <o>}) => %r(Expected wrappedGraph),
      %(GRAPH <g1> {<s> <p> <o>) => %r(Expected '}' following triple),
      %(GRAPH <g> {
        <s> <p> <o> .
        GRAPH <g1> { <s1> <p1> <o1>}
      }) => RDF::ReaderError,
      %(@graph <g> {<s> <p> <o>} .) => RDF::ReaderError,
      %(GRAPH <g> {
        <s> <p> <o> .
        prefix x: <http://example/x#>
        x:s1 x:p1 x:o1
      }) => RDF::ReaderError,
      %(GRAPH () { :s :p :o }) => %r(Expected label or subject),
      %(GRAPH (1 2) { :s :p :o }) => %r(Expected label or subject),
      %(<a> <b> <c>) => %r(Expected '.' following triple),
      %([:p1 :o1] {:s :p :o}) => %r(Expected '.' following triple),
      %((123) .) => %r(Expected predicateObjectList after collection subject),
    }.each_pair do |trig, error|
      context trig do
        it "should raise '#{error}' for '#{trig}'" do
          logger = RDF::Spec.logger
          logger.level = Logger::ERROR
          expect {
            parse("@prefix xsd: <http://www.w3.org/2001/XMLSchema#> . #{trig}",
              base_uri: "http://a/b",
              logger: logger,
              validate: true)
          }.to raise_error(RDF::ReaderError)

          expect(logger.to_s).to match(error) if error.is_a?(Regexp)
        end
      end
    end
  end
  
  describe "recovery" do
    {
      "base within a graph" => [
        %q({ @base <http://example.com/> . <a> <b> <c>}),
        %q(<a> <b> <c> .)
      ],
      "prefix within a graph" => [
        %q({ @prefix foo: <http://example.com/> . foo:a foo:b foo:c}),
        %q()
      ],
      "Literal graph identifier" => [
        %q("a" {<http://example.com/a> <http://example.com/b> <http://example.com/c> .}),
        %q()
      ],
      "malformed bnode subject" => [
        %q({_:.1 <http://example.com/a> <http://example.com/b> . _:bn <http://example.com/a> <http://example.com/c> .}),
        %q(_:bn <http://example.com/a> <http://example.com/c> .)
      ],
      "malformed bnode object(1)" => [
        %q({<http://example.com/a> <http://example.com/b> _:.1 . <http://example.com/a> <http://example.com/c> <http://example.com/d> .}),
        %q(<http://example.com/a> <http://example.com/c> <http://example.com/d> .)
      ],
      "malformed bnode object(2)" => [
        %q({
          <http://example.com/a> <http://example.com/b> _:-a;
                                 <http://example.com/c> <http://example.com/d> .
          <http://example/e> <http://example/f>  <http://example/g> .
        }),
        %q(<http://example/e> <http://example/f>  <http://example/g> .)
      ],
      "malformed bnode object(3)" => [
        %q({<http://example.com/a> <http://example.com/b> _:-a , <http://example.com/d> .}),
        %q()
      ],
      "malformed uri subject" => [
        %q({<"quoted"> <http://example.com/a> <http://example.com/b> . <http://example.com/c> <http://example.com/d> <http://example.com/e> .}),
        %q(<http://example.com/c> <http://example.com/d> <http://example.com/e> .)
      ],
      "malformed uri predicate(1)" => [
        %q({<http://example.com/a> <"quoted"> <http://example.com/b> . <http://example.com/c> <http://example.com/d> <http://example.com/e> .}),
        %q(<http://example.com/c> <http://example.com/d> <http://example.com/e> .)
      ],
      "malformed uri predicate(2)" => [
        %q({<http://example.com/a> <"quoted"> <http://example.com/b>; <http://example.com/d> <http://example.com/e> .}),
        %q()
      ],
      "malformed uri object(1)" => [
        %q({<http://example.com/a> <http://example.com/b> <"quoted"> . <http://example.com/c> <http://example.com/d> <http://example.com/e> .}),
        %q(<http://example.com/c> <http://example.com/d> <http://example.com/e> .)
      ],
      "malformed uri object(2)" => [
        %q({<http://example.com/a> <http://example.com/b> <"quoted">; <http://example.com/d> <http://example.com/e> .}),
        %q()
      ],
      "malformed uri object(3)" => [
        %q({<http://example.com/a> <http://example.com/b> "quoted">, <http://example.com/e> .}),
        %q()
      ],
    }.each do |test, (input, expected)|
      context test do
        it "raises an error if valiating" do
          expect {
            parse(input, validate: true)
          }.to raise_error RDF::ReaderError
        end
        
        it "continues after an error" do
          expect(parse(input, validate: false)).to be_equivalent_graph(expected, logger: @logger)
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
                :Monica ex:hasSkill ex:Management . }

          :G2 { :Monica rdf:type ex:Person .
                :Monica ex:hasSkill ex:Programming . }

          :G3 { :G1 swp:assertedBy _:w1 .
                _:w1 swp:authority :Chris .
                _:w1 dc:date "2003-10-02"^^xsd:date .   
                :G2 swp:quotedBy _:w2 .
                :G3 swp:assertedBy _:w2 .
                _:w2 dc:date "2003-09-03"^^xsd:date .
                _:w2 swp:authority :Chris .
                :Chris rdf:type ex:Person .  
                :Chris ex:email <mailto:chris@bizer.de> . }
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
        res = RDF::Repository.new << RDF::NQuads::Reader.new(expected)
        expect(parse(input)).to be_equivalent_graph(res, logger: @logger)
      end
    end
  end

  def parse(input, options = {})
    @logger = RDF::Spec.logger
    options = {
      logger: @logger,
      validate: false,
      canonicalize: false,
    }.merge(options)
    graph = options[:graph] || RDF::Repository.new
    RDF::TriG::Reader.new(input, options).each do |statement|
      graph << statement
    end
    graph
  end
end
