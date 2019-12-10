$:.unshift "."
require 'spec_helper'
require 'rdf/spec/writer'

describe RDF::TriG::Writer do
  let(:logger) {RDF::Spec.logger}

  it_behaves_like 'an RDF::Writer' do
    let(:writer) {RDF::TriG::Writer.new}
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
        expect(RDF::Writer.for(arg)).to eq RDF::TriG::Writer
      end
    end
  end

  describe "simple tests" do
    {
      "full URIs without base" => {
        input: %({<http://a/b> <http://a/c> <http://a/d> .}),
        regexp: [%r(^<http://a/b> <http://a/c> <http://a/d> \.$)],
      },
      "relative URIs with base" => {
        input: %({<http://a/b> <http://a/c> <http://a/d> .}),
        regexp: [ %r(^@base <http://a/> \.$), %r(^<b> <c> <d> \.$)],
        base_uri: "http://a/"
      },
      "pname URIs with prefix" => {
        input: %({<http://example.com/b> <http://example.com/c> <http://example.com/d> .}),
        regexp: [
          %r(^@prefix ex: <http://example.com/> \.$),
          %r(^ex:b ex:c ex:d \.$)
        ],
        prefixes: {ex: "http://example.com/"}
      },
      "pname URIs with empty prefix" => {
        input: %({<http://example.com/b> <http://example.com/c> <http://example.com/d> .}),
        regexp:  [
          %r(^@prefix : <http://example.com/> \.$),
          %r(^:b :c :d \.$)
        ],
        prefixes: {"" => "http://example.com/"}
      },
    }.each do |name, params|
      it name do
        serialize(params[:input], params[:regexp], **params)
      end

      it "#{name} (stream)" do
        serialize(params[:input], params.fetch(:regexp_stream, params[:regexp]), stream: true, **params)
      end
    end
  end

  context "Named Graphs" do
    {
      "default" => [
        %q({<a> <b> <c> .}),
        [
          %r(<a> <b> <c> \.?)m
        ]
      ],
      "named" => [
        %q(<C> {<a> <b> <c> .}),
        [
          %r(<C> \{\s*<a> <b> <c> \.?\s*\})m
        ]
      ],
      "named w/bnode" => [
        %q(_:C {<a> <b> <c> .}),
        [
          %r(_:C \{\s*<a> <b> <c> \.?\s*\})m
        ]
      ],
      "combo" => [
        %q(
          <a> <b> <c> .
          <C> {<A> <b> <c> .}
        ),
        [
          %r(^<a> <b> <c> .)m,
          %r(^<C> \{\s*<A> <b> <c> \.?\s*\})m
        ]
      ],
      "combo with duplicated statement" => [
        %q(
          <a> <b> <c> .
          <C> {<a> <b> <c> \.?}
        ),
        [
          %r(^<a> <b> <c> .)m,
          %r(^<C> \{\s*<a> <b> <c> \.\s*\})m
        ],
        [
          %r(^<a> <b> <c> .)m,
          %r(^<C> \{\s*<a> <b> <c> \s*\})m
        ]
      ],
      "combo with chained blankNodePropertyList" => [
        %q(
          <a> <b> _:c .
          _:c a <Class> .
          <C> {
            <d> <e> _:f .
            _:f a <Class> .
          }
        ),
        [
          %r(^<a> <b> \[\s*a <Class>\s*\] \.)m,
          %r(^<C> \{\s*<d> <e> \[\s*a <Class>\s*\] \.\s*\})m
        ],
        [
          %r(^<a> <b> _:c \.)m,
          %r(^\s+_:c a <Class> \.)m,
          %r(^<C> \{\s*<d> <e> _:f \.\s+_:f a <Class>\s*\})m
        ]
      ],
      "combo with graph name reference" => [
        %q(
          <a> <b> <C> .
          <C> {<d> <e> <f> .}
        ),
        [
          %r(^<a> <b> <C> .)m,
          %r(^<C> \{\s*<d> <e> <f> \.?\s*\})m
        ]
      ],
      "combo with bnode graph name reference" => [
        %q(
          <a> <b> _:C .
          _:C {<d> <e> <f> .}
        ),
        [
          %r(^<a> <b> _:C .)m,
          %r(^_:C \{\s*<d> <e> <f> \.?\s*\})m
        ]
      ]
    }.each_pair do |title, (input, matches, matches_stream)|
      it title do
        serialize(input, matches)
      end

      it "#{title} (stream)" do
        matches_stream ||= matches
        serialize(input, matches_stream, stream: true)
      end
    end
  end

  describe "lists" do
    {
      "bare list": {
        input: %(@prefix ex: <http://example.com/> . (ex:a ex:b) .),
        regexp: [%r(^\(\s*ex:a ex:b\s*\) \.$)]
      },
      "literal list": {
        input: %(@prefix ex: <http://example.com/> . ex:a ex:b ( "apple" "banana" ) .),
        regexp: [%r(^ex:a ex:b \(\s*"apple" "banana"\s*\) \.$)]
      },
      "empty list": {
        input: %(@prefix ex: <http://example.com/> . ex:a ex:b () .),
        regexp: [%r(^ex:a ex:b \(\s*\) \.$)]
      },
      "empty list as subject": {
        input: %(@prefix ex: <http://example.com/> . () ex:a ex:b .),
        regexp: [%r(^\(\s*\) ex:a ex:b \.$)]
      },
      "list as subject": {
        input: %(@prefix ex: <http://example.com/> . (ex:a) ex:b ex:c .),
        regexp: [%r(^\(\s*ex:a\s*\) ex:b ex:c \.$)]
      },
      "list of empties": {
        input: %(@prefix ex: <http://example.com/> . [ex:listOf2Empties (() ())] .),
        regexp: [%r(\[\s*ex:listOf2Empties \(\s*\(\s*\) \(\s*\)\s*\)\s*\] \.$)]
      },
      "list anon": {
        input: %(@prefix ex: <http://example.com/> . [ex:twoAnons ([a ex:mother] [a ex:father])] .),
        regexp: [%r(\[\s*ex:twoAnons \(\s*\[\s*a ex:mother\s*\] \[\s*a ex:father\s*\]\)\] \.$)]
      },
      "owl:unionOf list": {
        input: %(
          @prefix ex: <http://example.com/> .
          @prefix owl: <http://www.w3.org/2002/07/owl#> .
          @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
          @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
          ex:a rdfs:domain [
            a owl:Class;
            owl:unionOf [
              a owl:Class;
              rdf:first ex:b;
              rdf:rest [
                a owl:Class;
                rdf:first ex:c;
                rdf:rest rdf:nil
              ]
            ]
          ] .
        ),
        regexp: [
          %r(ex:a rdfs:domain \[\s*a owl:Class;\s+owl:unionOf\s+\(\s*ex:b\s+ex:c\s*\)\s*\]\s*\.$)m,
          %r(@prefix ex: <http://example.com/> \.),
          %r(@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \.),
        ]
      },
      "list with first subject a URI": {
        input: %(
          <http://example.com> <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "1"^^<http://www.w3.org/2001/XMLSchema#integer> .
          <http://example.com> <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g47006741228480 .
          _:g47006741228480 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "2"^^<http://www.w3.org/2001/XMLSchema#integer> .
          _:g47006741228480 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:g47006737917560 .
          _:g47006737917560 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "3"^^<http://www.w3.org/2001/XMLSchema#integer> .
          _:g47006737917560 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
        ),
        regexp: [
          %r(@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \.),
          %r(<http://example.com> rdf:first 1;),
          %r(rdf:rest \(\s*2 3\s*\) \.),
        ],
        standard_prefixes: true, format: :nquads
      },
      "list pattern without rdf:nil": {
        input: %(
          <http://example.com> <http://example.com/property> _:a .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "a" .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "b" .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "c" .
        ),
        regexp: [%r(<http://example.com> <http://example.com/property> \[),
          %r(rdf:first "a";),
          %r(rdf:rest \[),
          %r(rdf:first "b";),
          %r(rdf:rest \[\s*rdf:first "c"\s*\]),
        ],
        standard_prefixes: true, format: :nquads
      },
      "list pattern with extra properties": {
        input: %(
          <http://example.com> <http://example.com/property> _:a .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "a" .
          _:a <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:b .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "b" .
          _:a <http://example.com/other-property> "This list node has also properties other than rdf:first and rdf:rest" .
          _:b <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:c .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "c" .
          _:c <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> .
        ),
        regexp: [%r(<http://example.com> <http://example.com/property> \[),
          %r(<http://example.com/other-property> "This list node has also properties other than rdf:first and rdf:rest";),
          %r(rdf:first "a";),
          %r(rdf:rest \(\s*"b" "c"\s*\)),
        ],
        standard_prefixes: true, format: :nquads
      },
      "list with node shared across graphs": {
        input: %(
          <http://www.example.com/z> <http://www.example.com/q> _:z0 <http://www.example.com/G> .
          _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-A" <http://www.example.com/G> .
          _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:z1 <http://www.example.com/G> .
          _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-B" <http://www.example.com/G> .
          _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://www.example.com/G> .
          <http://www.example.com/x> <http://www.example.com/p> _:z1 <http://www.example.com/G1> .
        ),
        regexp: [
          %r(<http://www.example.com/G> {\s+<http://www.example.com/z> <http://www.example.com/q> \[)m,
          %r(rdf:first "cell-A";),
          %r(rdf:rest _:z1),
          %r(_:z1 rdf:first "cell-B";),
          %r(rdf:rest \(\)),
          %r(<http://www.example.com/G1> {\s+<http://www.example.com/x> <http://www.example.com/p> _:z1 .)m
        ],
        standard_prefixes: true, format: :nquads
      },
      "list with node shared across graphs (same triple in different graphs)": {
        input: %(
          <http://www.example.com/z> <http://www.example.com/q> _:z0 <http://www.example.com/G> .
          _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-A" <http://www.example.com/G> .
          _:z0 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> _:z1 <http://www.example.com/G> .
          _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> "cell-B" <http://www.example.com/G> .
          _:z1 <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> <http://www.w3.org/1999/02/22-rdf-syntax-ns#nil> <http://www.example.com/G> .
          <http://www.example.com/z> <http://www.example.com/q> _:z0 <http://www.example.com/G1> .
        ),
        regexp: [
          %r(<http://www.example.com/G> {\s+<http://www.example.com/z> <http://www.example.com/q> _:z0 .)m,
          %r(_:z0 rdf:first "cell-A";),
          %r(rdf:rest \(\s*"cell-B"\) .),
          %r(<http://www.example.com/G1> {\s+<http://www.example.com/z> <http://www.example.com/q> _:z0 .)m,
        ],
        standard_prefixes: true, format: :nquads
      }
    }.each do |name, params|
      it name do
        serialize(params[:input], params[:regexp], **params)
      end
    end
  end

  # W3C TriG Test suite
  describe "w3c trig tests" do
    require 'suite_helper'

    %w(manifest.ttl).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each do |t|
            next unless t.positive_test? && t.evaluate?
            specify "#{t.name}: #{t.comment}" do
              pending("native literals canonicalized") if t.name == "trig-subm-26"
              repo = parse(t.expected, format: :nquads)
              trig = serialize(repo, [], base_uri: t.base, standard_prefixes: true)
              logger.info t.inspect
              logger.info "source: #{t.expected}"
              logger.info "serialized: #{trig}"
              g2 = parse(trig, base_uri: t.base)
              expect(g2).to be_equivalent_graph(repo, logger: logger)
            end

            specify "#{t.name}: #{t.comment} (stream)" do
              pending("native literals canonicalized") if t.name == "trig-subm-26"
              repo = parse(t.expected, format: :nquads)
              trig = serialize(repo, [], stream: true, base_uri: t.base, standard_prefixes: true)
              logger.info t.inspect
              logger.info "source: #{t.expected}"
              logger.info "serialized: #{trig}"
              g2 = parse(trig, base_uri: t.base)
              expect(g2).to be_equivalent_graph(repo, logger: logger)
            end
          end
        end
      end
    end
  end unless ENV['CI']

  def parse(input, **options)
    reader = RDF::Reader.for(options.fetch(:format, :trig))
    reader.new(input, **options, &:each).to_a.extend(RDF::Enumerable)
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, regexps = [], base_uri: nil, **options)
    prefixes = options[:prefixes] || {}
    repo = ntstr.is_a?(RDF::Enumerable) ? ntstr : parse(ntstr, base_uri: base_uri, prefixes: prefixes, validate: false, logger: [], **options)
    logger.info "serialized: #{ntstr}"
    result = RDF::TriG::Writer.buffer(
      logger:   logger,
      base_uri: base_uri,
      prefixes: prefixes,
      encoding: Encoding::UTF_8,
      **options
    ) do |writer|
      writer << repo
    end

    logger.info "result: #{result}"
    regexps.each do |re|
      logger.info "match: #{re.inspect}"
      expect(result).to match_re(re, about: base_uri, logger: logger, input: ntstr), logger.to_s
    end
    
    result
  end
end