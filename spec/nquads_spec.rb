$:.unshift "."
require 'spec_helper'

describe RDF::NTriples::Reader do
  # W3C N-Quads Test suite from https://dvcs.w3.org/hg/rdf/file/default/nquds/tests/
  describe "w3c N-Quads tests" do
    require 'suite_helper'

    %w(
      rdf11/rdf-n-quads/manifest.ttl
      rdf12/rdf-n-quads/syntax/manifest.ttl
      rdf12/rdf-n-quads/c14n/manifest.ttl
    ).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              t.logger = RDF::Spec.logger
              t.logger.info t.inspect
              t.logger.info "source:\n#{t.input}"

              reader = RDF::NQuads::Reader.new(t.input, rdfstar: true, logger: t.logger, validate: true)

              repo = RDF::Repository.new

              if t.positive_test?
                begin
                  repo << reader
                rescue Exception => e
                  expect(e.message).to produce("Not exception #{e.inspect}", t.logger)
                end
              else
                expect {repo << reader}.to raise_error(RDF::ReaderError)
              end

              if t.c14n?
                c14n = RDF::NQuads::Writer.buffer {|w| w << repo}
                expect(c14n).to eql t.expected
              else
                expect(repo).to be_a(RDF::Enumerable)
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']