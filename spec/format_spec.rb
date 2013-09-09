$:.unshift "."
require 'spec_helper'
require 'rdf/spec/format'

describe RDF::TriG::Format do
  before :each do
    @format_class = RDF::TriG::Format
  end

  include RDF_Format

  describe ".for" do
    formats = [
      :trig,
      'etc/doap.trig',
      {:file_name      => 'etc/doap.trig'},
      {:file_extension => 'trig'},
      {:content_type   => 'application/trig'},
      {:content_type   => 'application/x-trig'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Format.for(arg)).to eq @format_class
      end
    end

    {
      :statement        => "{<a> <b> <c> .}",
      :multi_line       => %({\n<a>\n  <b>\n  "literal"\n .\n}),
      :trig             => "@prefix foo: <bar> .\n <> {foo:a foo:b <c> .}",
      :iri              => "@prefix foo: <bar> .\n <> <> {foo:a foo:b <c> .}",
      :pname            => "@prefix foo: <bar> .\n <> foo:pn {foo:a foo:b <c> .}",
      :STRING_LITERAL1  => %({<a> <b> 'literal' .}),
      :STRING_LITERAL2  => %({<a> <b> "literal" .}),
      :STRING_LITERAL_LONG1  => %({<a> <b> '''\nliteral\n''' .}),
      :STRING_LITERAL_LONG2  => %({<a> <b> """\nliteral\n""" .}),
    }.each do |sym, str|
      it "detects #{sym}" do
        expect(@format_class.for {str}).to eq @format_class
      end
    end

    it "should discover 'trig'" do
      expect(RDF::Format.for(:trig).reader).to eq RDF::TriG::Reader
    end
  end

  describe "#to_sym" do
    specify {expect(@format_class.to_sym).to eq :trig}
  end

  describe ".detect" do
    {
      :statement        => "{<a> <b> <c> .}",
      :multi_line       => %({\n<a>\n  <b>\n  "literal"\n .\n}),
      :trig             => "@prefix foo: <bar> .\n <> {foo:a foo:b <c> .}",
      :iri              => "@prefix foo: <bar> .\n <> <> {foo:a foo:b <c> .}",
      :pname            => "@prefix foo: <bar> .\n <> foo:pn {foo:a foo:b <c> .}",
      :STRING_LITERAL1  => %({<a> <b> 'literal' .}),
      :STRING_LITERAL2  => %({<a> <b> "literal" .}),
      :STRING_LITERAL_LONG1  => %({<a> <b> '''\nliteral\n''' .}),
      :STRING_LITERAL_LONG2  => %({<a> <b> """\nliteral\n""" .}),
    }.each do |sym, str|
      it "detects #{sym}" do
        expect(@format_class.detect(str)).to be_true
      end
    end

    {
      :ntriples         => "<a> <b> <c> .",
      :multi_line       => '<a>\n  <b>\n  "literal"\n .',
      :turtle           => "@prefix foo: <bar> .\n foo:a foo:b <c> .",
      :STRING_LITERAL1  => %(<a> <b> 'literal' .),
      :STRING_LITERAL2  => %(<a> <b> "literal" .),
      :STRING_LITERAL_LONG1  => %(<a> <b> '''\nliteral\n''' .),
      :STRING_LITERAL_LONG2  => %(<a> <b> """\nliteral\n""" .),
      :n3             => "@prefix foo: <bar> .\nfoo:bar = {<a> <b> <c>} .",
      :nquads => "<a> <b> <c> <d> . ",
      :rdfxml => '<rdf:RDF about="foo"></rdf:RDF>',
      :jsonld => '{"@context" => "foo"}',
      :rdfa   => '<div about="foo"></div>',
      :microdata => '<div itemref="bar"></div>',
    }.each do |sym, str|
      it "does not detect #{sym}" do
        expect(@format_class.detect(str)).to be_false
      end
    end
  end
end
