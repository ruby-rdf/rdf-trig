$:.unshift "."
require 'spec_helper'
require 'rdf/spec/writer'

describe RDF::TriG::Writer do
  before(:each) {$stderr, @old_stderr = StringIO.new, $stderr}
  after(:each) {$stderr = @old_stderr}
  before(:each) do
    @writer = RDF::TriG::Writer.new(StringIO.new)
  end
  
  include RDF_Writer

  # XXX This should work for Ruby 1.8, but don't have time to investigate further right now
  describe ".for" do
    formats = [
      :trig,
      'etc/doap.trig',
      {:file_name      => 'etc/doap.trig'},
      {:file_extension => 'trig'},
      {:content_type   => 'application/trig'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Writer.for(arg)).to eq RDF::TriG::Writer
      end
    end
  end

  describe "simple tests" do
    it "should use full URIs without base" do
      input = %({<http://a/b> <http://a/c> <http://a/d> .})
      serialize(input, nil, [%r(<http://a/b> <http://a/c> <http://a/d> \.$)m])
    end

    it "should use relative URIs with base" do
      input = %({<http://a/b> <http://a/c> <http://a/d> .})
      serialize(input, "http://a/",
       [ %r(^@base <http://a/> \.$),
        %r(^<b> <c> <d> \.$)m]
      )
    end

    it "should use pname URIs with prefix" do
      input = %({<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .})
      serialize(input, nil,
        [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
        %r(^foaf:b foaf:c foaf:d \.$)m],
        :prefixes => { :foaf => RDF::FOAF}
      )
    end

    it "should use pname URIs with empty prefix" do
      input = %({<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .})
      serialize(input, nil,
        [%r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
        %r(^:b :c :d \.$)m],
        :prefixes => { "" => RDF::FOAF}
      )
    end
    
    # see example-files/arnau-registered-vocab.rb
    it "should use pname URIs with empty suffix" do
      input = %({<http://xmlns.com/foaf/0.1/> <http://xmlns.com/foaf/0.1/> <http://xmlns.com/foaf/0.1/> .})
      serialize(input, nil,
        [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
        %r(^foaf: foaf: foaf: \.$)m],
        :prefixes => { "foaf" => RDF::FOAF}
      )
    end
    
    it "should order properties" do
      input = %(
        @prefix : <http://xmlns.com/foaf/0.1/> .
        @prefix dc: <http://purl.org/dc/elements/1.1/> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        {
          :b :c :d .
          :b dc:title "title" .
          :b a :class .
          :b rdfs:label "label" .
        }
      )
      serialize(input, nil,
        [
          %r(^:b)m,
          %r(^:b a :class;$)m,
          %r(\s+:class;\s+rdfs:label "label";)m,
          %r(\s+"label";\s+dc:title "title";)m,
          %r(\s+"title";\s+:c :d \.$)m
        ],
        :prefixes => { "" => RDF::FOAF, :dc => "http://purl.org/dc/elements/1.1/", :rdfs => RDF::RDFS}
      )
    end
    
    it "should generate object list" do
      input = %(@prefix : <http://xmlns.com/foaf/0.1/> . {:b :c :d, :e .})
      serialize(input, nil,
        [
          %r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
          %r(^:b)m,
          %r(^:b :c :d,$),
          %r(^\s+:e \.$)
        ],
        :prefixes => { "" => RDF::FOAF}
      )
    end
    
    it "should generate property list" do
      input = %(@prefix : <http://xmlns.com/foaf/0.1/> . {:b :c :d; :e :f .})
      serialize(input, nil,
        [
          %r(^@prefix : <http://xmlns.com/foaf/0.1/> \.$),
          %r(^\s+:b :c :d;$)m,
          %r(:d;\s+:e :f \.)m,
          %r(:f \.\s+$)m,
        ],
        :prefixes => { "" => RDF::FOAF}
      )
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
          %r(^<C> \{\s*<a> <b> <c> .\s*\})m
        ]
      ],
    }.each_pair do |title, (input, matches)|
      it title do
        serialize(input, nil, matches)
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
            specify "#{t.name}: #{t.comment}", pending: (t.name == 'collection_subject') do
              repo = parse(t.expected, format: :nquads)
              trig = serialize(repo, t.base, [], base_uri: t.base, standard_prefixes: true)
              @debug += [t.inspect, "source:", t.expected, "result:", trig]
              g2 = parse(trig, base_uri: t.base)
              expect(g2).to be_equivalent_dataset(repo, trace: @debug)
            end

            specify "#{t.name}: #{t.comment} (stream)" do
              repo = parse(t.expected, format: :nquads)
              trig = serialize(repo, t.base, [], :stream => true, base_uri: t.base, standard_prefixes: true)
              @debug += [t.inspect, "source:", t.expected, "result:", trig]
              g2 = parse(trig, base_uri: t.base)
              expect(g2).to be_equivalent_dataset(repo, trace: @debug)
            end
          end
        end
      end
    end
  end unless ENV['CI']

  def parse(input, options = {})
    reader = RDF::Reader.for(options.fetch(:format, :trig))
    RDF::Repository.new << reader.new(input, options)
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, base = nil, regexps = [], options = {})
    prefixes = options[:prefixes] || {}
    repo = ntstr.is_a?(RDF::Enumerable) ? ntstr : parse(ntstr, :base_uri => base, :prefixes => prefixes)
    @debug = []
    result = RDF::TriG::Writer.buffer(options.merge(:debug => @debug, :base_uri => base, :prefixes => prefixes)) do |writer|
      writer << repo
    end
    if $verbose
      require 'cgi'
      #puts CGI.escapeHTML(result)
    end
    
    regexps.each do |re|
      expect(result).to match_re(re, :about => base, :trace => @debug, :input => ntstr)
    end
    
    result
  end
end