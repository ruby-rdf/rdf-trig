$:.unshift "."
require 'spec_helper'

describe RDF::TriG::Reader do
  describe "w3c TriG tests" do
    require 'suite_helper'

    # TriG/manifest.ttl
    %w().each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              if false
                t.debug = [t.inspect, "source:", t.input.read]

                reader = RDF::Turtle::Reader.new(t.input,
                    :base_uri => t.base,
                    :canonicalize => false,
                    :validate => true,
                    :debug => t.debug)

                graph = RDF::Repository.new

                if t.positive_test?
                  begin
                    graph << reader
                  rescue Exception => e
                    e.message.should produce("Not exception #{e.inspect}", t.debug)
                  end
                else
                  lambda {
                    graph << reader
                  }.should raise_error(RDF::ReaderError)
                end

                if t.evaluate?
                  output_graph = RDF::Repository.load(t.result, :format => :nquads, :base_uri => t.base)
                  graph.should be_equivalent_graph(output_graph, t)
                else
                  graph.should be_a(RDF::Enumerable)
                end
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']