$:.unshift "."
require 'spec_helper'

describe RDF::TriG::Reader do
  describe "w3c TriG tests" do
    require 'suite_helper'

    # TriG/manifest.ttl
    %w(manifest.ttl).each do |man|
      Fixtures::SuiteTest::Manifest.open(Fixtures::SuiteTest::BASE + man) do |m|
        describe m.comment do
          m.entries.each do |t|
            specify "#{t.name}: #{t.comment}" do
              case t.name
              when false
              else
                t.debug = [t.inspect, "source:", t.input]
                t.warnings = []
                t.errors = []

                reader = RDF::TriG::Reader.new(t.input,
                    base_uri: t.base,
                    errors: t.errors,
                    warnings: t.warnings,
                    canonicalize: false,
                    validate: true,
                    debug: t.debug)

                repo = RDF::Repository.new

                if t.positive_test?
                  begin
                    repo << reader
                  rescue Exception => e
                    expect(e.message).to produce("Not exception #{e.inspect}", t)
                  end
                else
                  expect {
                    repo << reader
                    expect(repo.dump(:nquads)).to produce("not this", t)
                  }.to raise_error(RDF::ReaderError)
                end

                if t.evaluate? && t.positive_test?
                  output_repo = RDF::Repository.load(t.result, format: :nquads, base_uri: t.base)
                  expect(repo).to be_equivalent_dataset(output_repo, t)
                elsif !t.evaluate?
                  expect(repo).to be_a(RDF::Enumerable)
                end
              end
            end
          end
        end
      end
    end
  end
end unless ENV['CI']