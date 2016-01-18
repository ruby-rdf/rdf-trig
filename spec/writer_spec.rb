$:.unshift "."
require 'spec_helper'
require 'rdf/spec/writer'

describe RDF::TriG::Writer do
  let(:logger) {RDF::Spec.logger}
  after(:each) {|example| puts logger.to_s if example.exception}

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
        base: "http://a/"
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
        serialize(params[:input], params[:base], params[:regexp], params)
      end

      it "#{name} (stream)" do
        serialize(params[:input], params[:base], params.fetch(:regexp_stream, params[:regexp]), params.merge(stream: true))
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
      "combo with chained blankNodePropertyList " => [
        %q(
          <a> <b> _:c .
          _:c a <Class> .
          <C> {
            <d> <e> _:f .
            _:f a <Class> .
          }
        ),
        [
          %r(^<a> <b> \[ a <Class>\] \.)m,
          %r(^<C> \{\s*<d> <e> \[ a <Class>\] \.\s*\})m
        ],
        []
      ],
    }.each_pair do |title, (input, matches, matches_stream)|
      it title do
        serialize(input, nil, matches)
      end

      it "#{title} (stream)" do
        matches_stream ||= matches
        serialize(input, nil, matches_stream, stream: true)
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
              trig = serialize(repo, t.base, [], base_uri: t.base, standard_prefixes: true)
              logger.info t.inspect
              logger.info "source: #{t.expected}"
              logger.info "serialized: #{trig}"
              g2 = parse(trig, base_uri: t.base)
              expect(g2).to be_equivalent_graph(repo, logger: logger)
            end

            specify "#{t.name}: #{t.comment} (stream)" do
              pending("native literals canonicalized") if t.name == "trig-subm-26"
              repo = parse(t.expected, format: :nquads)
              trig = serialize(repo, t.base, [], stream: true, base_uri: t.base, standard_prefixes: true)
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

  def parse(input, options = {})
    reader = RDF::Reader.for(options.fetch(:format, :trig))
    reader.new(input, options, &:each).to_a.extend(RDF::Enumerable)
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, base = nil, regexps = [], options = {})
    prefixes = options[:prefixes] || {}
    repo = ntstr.is_a?(RDF::Enumerable) ? ntstr : parse(ntstr, base_uri: base, prefixes: prefixes, validate: false, logger: [])
    logger.info "serialized: #{ntstr}"
    result = RDF::TriG::Writer.buffer(options.merge(
      logger:   logger,
      base_uri: base,
      prefixes: prefixes,
      encoding: Encoding::UTF_8
    )) do |writer|
      writer << repo
    end
    
    regexps.each do |re|
      expect(result).to match_re(re, about: base, logger: logger, input: ntstr)
    end
    
    result
  end
end