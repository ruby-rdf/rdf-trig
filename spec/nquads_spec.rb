$:.unshift "."
require 'spec_helper'

describe RDF::NTriples::Reader do
  # W3C N-Quads Test suite from https://dvcs.w3.org/hg/rdf/file/default/nquds/tests/
  describe "w3c N-Quads tests" do
    require 'suite_helper'

    [Fixtures::SuiteTest::NTBASE, Fixtures::SuiteTest::NQBASE].each do |base|
      Fixtures::SuiteTest::Manifest.open("#{base}manifest.ttl") do |m|
        describe m.comment do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              t.debug = [t.inspect, "source:", t.input.read]

              reader = RDF::NQuads::Reader.new(t.input,
                  :validate => true)

              repo = RDF::Repository.new

              if t.positive_test?
                begin
                  repo << reader
                rescue Exception => e
                  e.message.should produce("Not exception #{e.inspect}", t.debug)
                end
              else
                expect {repo << reader}.to raise_error
              end

              repo.should be_a(RDF::Enumerable)
            end
          end
        end
      end
    end
  end
end unless ENV['CI']