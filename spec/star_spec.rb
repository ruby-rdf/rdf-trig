$:.unshift "."
require 'spec_helper'

describe RDF::TriG::Reader do
  # W3C Turtle Test suite from http://w3c.github.io/rdf-tests/rdf/rdf11/rdf-trig/manifest.ttl
  describe "rdfstar TriG tests" do
    require 'suite_helper'

    %w(
      rdf12/rdf-n-triples/syntax/manifest.ttl
      rdf12/rdf-trig/syntax/manifest.ttl
      rdf12/rdf-trig/eval/manifest.ttl).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe [m.label, m.comment].compact.join(': ') do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              t.logger = RDF::Spec.logger
              t.logger.info t.inspect
              t.logger.info "source:\n#{t.input}"

              reader = RDF::Reader.for(t.action).new(t.input,
                  base_uri:  t.base,
                  canonicalize:  false,
                  validate:  true,
                  rdfstar: true,
                  logger: t.logger)

              graph = RDF::Repository.new

              if t.positive_test?
                begin
                  graph << reader
                rescue Exception => e
                  expect(e.message).to produce("Not exception #{e.inspect}", t)
                end

                if t.evaluate?
                  output_graph = RDF::Repository.load(t.result, format: :nquads, rdfstar: true, base_uri:  t.base)
                  expect(graph).to be_equivalent_graph(output_graph, t)
                else
                  expect(graph).to be_a(RDF::Enumerable)
                end
              else
                expect {
                  graph << reader
                  expect(graph.dump(:nquads, rdfstar: true)).to produce("not this", t)
                }.to raise_error(RDF::ReaderError)
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']