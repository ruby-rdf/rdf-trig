$:.unshift "."
require 'spec_helper'

describe RDF::TriG::Reader do
  describe "w3c TriG tests" do
    require 'suite_helper'

    # TriG/manifest.ttl
    %w(manifest.ttl ../tests2/manifest.ttl).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              case t.name
              when false
              else
                t.debug = [t.inspect, "source:", t.input.read]

                reader = RDF::TriG::Reader.new(t.input,
                    :base_uri => t.base,
                    :canonicalize => false,
                    :validate => true,
                    :debug => t.debug)

                repo = RDF::Repository.new

                if t.positive_test?
                  begin
                    repo << reader
                  rescue Exception => e
                    e.message.should produce("Not exception #{e.inspect}", t.debug)
                  end
                else
                  lambda {
                    repo << reader
                  }.should raise_error(RDF::ReaderError)
                end

                if t.evaluate? && t.positive_test?
                  output_repo = RDF::Repository.load(t.result, :format => :nquads, :base_uri => t.base)
                  repo.should be_equivalent_dataset(output_repo, t)
                elsif !t.evaluate?
                  repo.should be_a(RDF::Enumerable)
                end
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']